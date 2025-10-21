import pandas as pd

df = pd.read_csv(r"C:\Program Files\Analysis\Urban Basket Sales 2024 (Clean).csv")
df["transaction_date"] = pd.to_datetime(df["transaction_date"])

start_date = "2024-10-01"
end_date = "2024-12-31"

mask = (df["transaction_date"] >= start_date) & (df["transaction_date"] <= end_date)
quarter_df = df.loc[mask]


# Volume & Value Metrics
total_sales = quarter_df["total_spent"].sum()
number_of_transactions = quarter_df["transaction_id"].nunique()
average_order_value = total_sales / number_of_transactions
total_quantity = quarter_df["quantity"].sum()


# Catergory Performence
top_categories = quarter_df.groupby("category")["total_spent"].sum().sort_values(ascending=False)
top_items = quarter_df.groupby("item")["quantity"].sum().sort_values(ascending=False)

# Sales by Payment method and Location
sales_by_payment = quarter_df.groupby("payment_method")["total_spent"].sum().sort_values(ascending=False)
sales_by_location = quarter_df.groupby("location")["total_spent"].sum().sort_values(ascending=False)

# Weekly Sales
quarter_df["transaction_date"] = pd.to_datetime(quarter_df["transaction_date"])
custom_start = pd.to_datetime("2024-01-01")
quarter_df.loc[:, "custom_week"] = ((quarter_df["transaction_date"] - custom_start).dt.days // 7) + 1
weekly_sales = quarter_df.groupby("custom_week")["total_spent"].sum().reset_index().sort_values("custom_week")

# Sales by day of week
quarter_df.loc[:, "day_of_week"] = quarter_df["transaction_date"].dt.day_of_week
weekday_sales = quarter_df.groupby("day_of_week")["total_spent"].mean().sort_index()

# Items per Transaction
items_per_txn = quarter_df.groupby("transaction_id")["quantity"].sum()
avg_items_per_txn = items_per_txn.mean()





