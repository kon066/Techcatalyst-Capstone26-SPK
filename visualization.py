import streamlit as st
import snowflake.connector
import pandas as pd
import geopandas as gpd
import configparser
import folium

from shapely import wkt
from streamlit_folium import st_folium
from branca.colormap import linear

# ----------------------------------------
# Page Config
# ----------------------------------------

st.set_page_config(
    page_title="NYC Taxi Zone Analytics",
    layout="wide"
)

# ----------------------------------------
# Analysis Type
# ----------------------------------------

analysis_type = st.radio(
    "Analysis Type",
    [
        "Pickup Zones",
        "Dropoff Zones",
        "Net Flow"
    ],
    horizontal=True
)

# ----------------------------------------
# Connect to Snowflake
# ----------------------------------------

config = configparser.ConfigParser()
config.read("snow.cfg")

conn = snowflake.connector.connect(
    user=config["SNOWFLAKE"]["user"],
    password=config["SNOWFLAKE"]["password"],
    account=config["SNOWFLAKE"]["account"],
    warehouse=config["SNOWFLAKE"]["warehouse"],
    database=config["SNOWFLAKE"]["database"],
    schema=config["SNOWFLAKE"]["schema"],
    role=config["SNOWFLAKE"]["role"]
)

# ----------------------------------------
# Query Data
# ----------------------------------------

if analysis_type == "Pickup Zones":

    query = """
    SELECT
        p.*,
        d.GEOMETRY_WKT
    FROM MART_ZONE_PROFITABILITY p
    INNER JOIN MART_ZONE_DEMAND d
        ON p.PICKUP_LOCATION_ID = d.PICKUP_LOCATION_ID
    WHERE p.PICKUP_BOROUGH NOT IN ('N/A', 'Unknown')
    """

elif analysis_type == "Dropoff Zones":

    query = """
    WITH dropoff_metrics AS (

        SELECT
            DO_LOCATION_ID AS LOCATION_ID,
            DO_NAME AS PICKUP_ZONE,
            DO_BOROUGH AS PICKUP_BOROUGH,

            COUNT(*) AS TRIP_COUNT,
            SUM(TOTAL_AMOUNT) AS TOTAL_REVENUE,
            AVG(TOTAL_AMOUNT) AS REVENUE_PER_TRIP,
            AVG(TRIP_DISTANCE) AS AVG_TRIP_DISTANCE,
            AVG(FARE_AMOUNT) AS AVG_FARE,
            AVG(REVENUE_PER_MILE) AS REVENUE_PER_MILE

        FROM MART_TAXI_TRIP_ANALYTICS

        WHERE DO_BOROUGH NOT IN ('N/A','Unknown')

        GROUP BY
            DO_LOCATION_ID,
            DO_NAME,
            DO_BOROUGH
    )

    SELECT
        m.*,
        g.GEOMETRY_WKT
    FROM dropoff_metrics m
    INNER JOIN MART_ZONE_DEMAND g
        ON m.LOCATION_ID = g.PICKUP_LOCATION_ID
    """

else:

    query = """
    WITH pickups AS (

        SELECT
            PU_LOCATION_ID AS LOCATION_ID,
            COUNT(*) AS PICKUP_COUNT
        FROM MART_TAXI_TRIP_ANALYTICS
        GROUP BY PU_LOCATION_ID

    ),

    dropoffs AS (

        SELECT
            DO_LOCATION_ID AS LOCATION_ID,
            COUNT(*) AS DROPOFF_COUNT
        FROM MART_TAXI_TRIP_ANALYTICS
        GROUP BY DO_LOCATION_ID

    )

    SELECT
        g.PICKUP_LOCATION_ID,
        g.PICKUP_ZONE,
        g.PICKUP_BOROUGH,
        g.GEOMETRY_WKT,

        COALESCE(p.PICKUP_COUNT,0) AS PICKUP_COUNT,
        COALESCE(d.DROPOFF_COUNT,0) AS DROPOFF_COUNT,

        COALESCE(p.PICKUP_COUNT,0)
        -
        COALESCE(d.DROPOFF_COUNT,0)
        AS NET_FLOW

    FROM MART_ZONE_DEMAND g

    LEFT JOIN pickups p
        ON g.PICKUP_LOCATION_ID = p.LOCATION_ID

    LEFT JOIN dropoffs d
        ON g.PICKUP_LOCATION_ID = d.LOCATION_ID

    WHERE g.PICKUP_BOROUGH NOT IN ('N/A','Unknown')
    """

df = pd.read_sql(query, conn)

conn.close()

# ----------------------------------------
# Geometry
# ----------------------------------------

df["geometry"] = df["GEOMETRY_WKT"].apply(wkt.loads)

gdf = gpd.GeoDataFrame(
    df,
    geometry="geometry"
)

gdf = gdf.set_crs("EPSG:2263")
gdf = gdf.to_crs(epsg=4326)

# ----------------------------------------
# Title
# ----------------------------------------

st.title("NYC Taxi Zone Analytics")

# ----------------------------------------
# Borough Filter
# ----------------------------------------

boroughs = sorted(
    gdf["PICKUP_BOROUGH"].dropna().unique()
)

selected_borough = st.selectbox(
    "Borough Filter",
    ["All"] + boroughs
)

if selected_borough != "All":
    gdf = gdf[
        gdf["PICKUP_BOROUGH"]
        == selected_borough
    ]

# ----------------------------------------
# KPI Cards
# ----------------------------------------

col1, col2, col3, col4 = st.columns(4)

if analysis_type == "Net Flow":

    with col1:
        st.metric(
            "Total Pickups",
            f"{gdf['PICKUP_COUNT'].sum():,.0f}"
        )

    with col2:
        st.metric(
            "Total Dropoffs",
            f"{gdf['DROPOFF_COUNT'].sum():,.0f}"
        )

    with col3:
        st.metric(
            "Max Net Flow",
            f"{gdf['NET_FLOW'].max():,.0f}"
        )

    with col4:
        st.metric(
            "Min Net Flow",
            f"{gdf['NET_FLOW'].min():,.0f}"
        )

else:

    with col1:
        st.metric(
            "Trips",
            f"{gdf['TRIP_COUNT'].sum():,.0f}"
        )

    with col2:
        st.metric(
            "Revenue",
            f"${gdf['TOTAL_REVENUE'].sum():,.0f}"
        )

    with col3:
        st.metric(
            "Avg Revenue / Trip",
            f"${gdf['REVENUE_PER_TRIP'].mean():.2f}"
        )

    with col4:
        st.metric(
            "Avg Revenue / Mile",
            f"${gdf['REVENUE_PER_MILE'].mean():.2f}"
        )

# ----------------------------------------
# Metrics
# ----------------------------------------

if analysis_type == "Net Flow":

    metrics = {
        "Net Flow": (
            "NET_FLOW",
            "Net Flow"
        ),
        "Pickups": (
            "PICKUP_COUNT",
            "Pickup Count"
        ),
        "Dropoffs": (
            "DROPOFF_COUNT",
            "Dropoff Count"
        )
    }

else:

    metrics = {
        "Trips": (
            "TRIP_COUNT",
            "Total Trips"
        ),
        "Revenue": (
            "TOTAL_REVENUE",
            "Total Revenue ($)"
        ),
        "Revenue / Trip": (
            "REVENUE_PER_TRIP",
            "Revenue Per Trip ($)"
        ),
        "Revenue / Mile": (
            "REVENUE_PER_MILE",
            "Revenue Per Mile ($)"
        ),
        "Avg Fare": (
            "AVG_FARE",
            "Average Fare ($)"
        ),
        "Avg Distance": (
            "AVG_TRIP_DISTANCE",
            "Average Trip Distance"
        )
    }

st.subheader("Map Analysis")

if "selected_metric" not in st.session_state:
    st.session_state.selected_metric = "TRIP_COUNT"

metric_names = list(metrics.keys())

selected_metric_name = st.radio(
    "Map Metric",
    metric_names,
    horizontal=True
)

color_metric = metrics[selected_metric_name][0]
legend_label = metrics[selected_metric_name][1]

# ----------------------------------------
# Map Setup
# ----------------------------------------

bounds = gdf.total_bounds

center_lon = (bounds[0] + bounds[2]) / 2
center_lat = (bounds[1] + bounds[3]) / 2

m = folium.Map(
    location=[center_lat, center_lon],
    zoom_start=10,
    tiles="CartoDB Positron"
)

# ----------------------------------------
# Color Scale
# ----------------------------------------

total_metrics = [
    "TRIP_COUNT",
    "TOTAL_REVENUE",
    "PICKUP_COUNT",
    "DROPOFF_COUNT",
    "NET_FLOW"
]

if color_metric in total_metrics:

    lower = gdf[color_metric].quantile(0.05)
    upper = gdf[color_metric].quantile(0.95)

else:

    lower = float(gdf[color_metric].min())
    upper = float(gdf[color_metric].max())

if analysis_type == "Net Flow":

    max_abs = max(
        abs(lower),
        abs(upper)
    )

    colormap = linear.RdYlGn_11.scale(
        -max_abs,
        max_abs
    )

else:

    colormap = linear.YlOrRd_09.scale(
        lower,
        upper
    )

colormap.width = 700
colormap.caption = legend_label

# ----------------------------------------
# Zone Layer
# ----------------------------------------

folium.GeoJson(
    gdf,
    style_function=lambda feature: {
        "fillColor": colormap(
            max(
                lower,
                min(
                    feature["properties"][color_metric],
                    upper
                )
            )
        ),
        "color": "#444444",
        "weight": 0.75,
        "fillOpacity": 0.80
    },
    highlight_function=lambda feature: {
        "weight": 2.5,
        "color": "#000000",
        "fillOpacity": 0.95
    },
    tooltip=folium.GeoJsonTooltip(
        fields=[
            "PICKUP_ZONE",
            "PICKUP_BOROUGH",
            color_metric
        ],
        aliases=[
            "Zone",
            "Borough",
            legend_label
        ],
        localize=True,
        sticky=True,
        labels=True
    )
).add_to(m)

colormap.add_to(m)

# ----------------------------------------
# Render Map
# ----------------------------------------

st_folium(
    m,
    width=1400,
    height=800
)

# ----------------------------------------
# Top Zones Table
# ----------------------------------------

st.subheader(f"Top 15 Zones by {legend_label}")

if analysis_type == "Net Flow":

    top_df = (
        gdf[
            [
                "PICKUP_ZONE",
                "PICKUP_BOROUGH",
                "PICKUP_COUNT",
                "DROPOFF_COUNT",
                "NET_FLOW"
            ]
        ]
        .sort_values(
            color_metric,
            ascending=False
        )
        .head(15)
    )

else:

    top_df = (
        gdf[
            [
                "PICKUP_ZONE",
                "PICKUP_BOROUGH",
                "TRIP_COUNT",
                "TOTAL_REVENUE",
                "REVENUE_PER_TRIP",
                "REVENUE_PER_MILE",
                "AVG_FARE",
                "AVG_TRIP_DISTANCE"
            ]
        ]
        .sort_values(
            color_metric,
            ascending=False
        )
        .head(15)
    )

st.dataframe(
    top_df,
    use_container_width=True
)