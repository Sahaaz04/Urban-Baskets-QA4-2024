import pandas as pd

# Load and prepare data
df = pd.read_csv(r"C:\Program Files\Analysis\Urban Basket Sales 2024 (Clean).csv")
df["transaction_date"] = pd.to_datetime(df["transaction_date"])

# Define quarters

q4_2024 = df[df["transaction_date"].between("2024-10-01", "2024-12-31")]  # Q4 2024
q3_2024 = df[df["transaction_date"].between("2024-07-01", "2024-09-30")]  # Q3 2024
q4_2023 = df[df["transaction_date"].between("2023-10-01", "2023-12-31")]  # Q4 2023

# Volume & Value Metrics
total_sales = q4_2024["total_spent"].sum()
number_of_transactions = q4_2024["transaction_id"].nunique()
average_order_value = total_sales / number_of_transactions
total_quantity = q4_2024["quantity"].sum()

# QoQ & YoY Comparison
def get_metrics(df):
    return {
        "sales": df["total_spent"].sum(),
        "transactions": df["transaction_id"].nunique(),
        "aov": df["total_spent"].sum() / df["transaction_id"].nunique()
    }

metrics_q4_2024 = get_metrics(q4_2024)
metrics_q3_2024 = get_metrics(q3_2024)
metrics_q4_2023 = get_metrics(q4_2023)

# QoQ and YoY Sales
qoq_sales_change = ((metrics_q4_2024["sales"] - metrics_q3_2024["sales"]) / metrics_q3_2024["sales"]) * 100

yoy_sales_change = ((metrics_q4_2024["sales"] - metrics_q4_2023["sales"]) / metrics_q4_2023["sales"]) * 100

# Category Performance
top_categories = q4_2024.groupby("category")["total_spent"].sum().sort_values(ascending=False)
top_items = q4_2024.groupby("item")["quantity"].sum().sort_values(ascending=False)

# Sales by Payment method and Location
sales_by_payment = q4_2024.groupby("payment_method")["total_spent"].sum().sort_values(ascending=False)
sales_by_location = q4_2024.groupby("location")["total_spent"].sum().sort_values(ascending=False)

#  Weekly Sales 
q4_2024["custom_week"] = ((q4_2024["transaction_date"] - custom_start).dt.days // 7) + 1
weekly_sales = q4_2024.groupby("custom_week")["total_spent"].sum().reset_index().sort_values("custom_week")

# Sales by Day of Week 
q4_2024["day_of_week"] = q4_2024["transaction_date"].dt.day_of_week
weekday_sales = q4_2024.groupby("day_of_week")["total_spent"].mean().sort_index()

# Items per Transaction 
items_per_txn = q4_2024.groupby("transaction_id")["quantity"].sum()
avg_items_per_txn = items_per_txn.mean()





