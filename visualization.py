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
    page_title="NYC Taxi Zone Demand",
    layout="wide"
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

query = """
SELECT *
FROM MART_ZONE_DEMAND
WHERE PICKUP_BOROUGH NOT IN ('N/A', 'Unknown')
"""

df = pd.read_sql(query, conn)

conn.close()

# ----------------------------------------
# Convert WKT -> Geometry
# ----------------------------------------

df["geometry"] = df["GEOMETRY_WKT"].apply(wkt.loads)

gdf = gpd.GeoDataFrame(
    df,
    geometry="geometry"
)

# Restore original CRS from taxi_zones.shp
gdf = gdf.set_crs("EPSG:2263")

# Convert to latitude/longitude for Folium
gdf = gdf.to_crs(epsg=4326)

# ----------------------------------------
# Header
# ----------------------------------------

st.title("NYC Taxi Zone Demand")

metric_col1, metric_col2 = st.columns(2)

with metric_col1:
    st.metric(
        "Total Trips",
        f"{gdf['TRIP_COUNT'].sum():,.0f}"
    )

with metric_col2:
    st.metric(
        "Total Revenue",
        f"${gdf['TOTAL_REVENUE'].sum():,.2f}"
    )

# ----------------------------------------
# Metric Buttons
# ----------------------------------------

st.subheader("Map Coloring")

btn_col1, btn_col2 = st.columns(2)

if "selected_metric" not in st.session_state:
    st.session_state.selected_metric = "TRIP_COUNT"

with btn_col1:
    if st.button(
        "Total Trips",
        use_container_width=True
    ):
        st.session_state.selected_metric = "TRIP_COUNT"

with btn_col2:
    if st.button(
        "Total Revenue",
        use_container_width=True
    ):
        st.session_state.selected_metric = "TOTAL_REVENUE"

color_metric = st.session_state.selected_metric

legend_label = (
    "Total Trips"
    if color_metric == "TRIP_COUNT"
    else "Total Revenue ($)"
)

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

colormap = linear.YlOrRd_09.scale(
    float(gdf[color_metric].min()),
    float(gdf[color_metric].max())
)

# Makes the legend much cleaner
colormap = colormap.to_step(6)
colormap.caption = legend_label

# ----------------------------------------
# Zone Layer
# ----------------------------------------

folium.GeoJson(
    gdf,
    style_function=lambda feature: {
        "fillColor": colormap(
            feature["properties"][color_metric]
        ),
        "color": "#444444",
        "weight": 0.75,
        "fillOpacity": 0.80,
    },
    highlight_function=lambda feature: {
        "weight": 2.5,
        "color": "#000000",
        "fillOpacity": 0.95,
    },
    tooltip=folium.GeoJsonTooltip(
        fields=[
            "PICKUP_ZONE",
            "PICKUP_BOROUGH",
            "TRIP_COUNT",
            "TOTAL_REVENUE",
            "AVG_REVENUE_PER_TRIP",
            "AVG_FARE",
            "AVG_TIP_CREDIT_CARD_ONLY",
            "AVG_TRIP_DISTANCE"
        ],
        aliases=[
            "Zone",
            "Borough",
            "Total Trips",
            "Total Revenue",
            "Avg Revenue / Trip",
            "Avg Fare",
            "Avg Credit Card Tip",
            "Avg Trip Distance"
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