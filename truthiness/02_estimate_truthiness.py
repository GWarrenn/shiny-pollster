import json
import pandas as pd
import re

results = pd.read_csv('C:\\users\\augus\\desktop\\truthiness\\raw_truthiness.csv')

results['pd_date'] = pd.to_datetime(results['date'])

results['total_statements'] = results.groupby('name').cumcount(ascending=False) + 1

results['total_true'] = results.sort_values(by=['date'],ascending=False).groupby('name')['true'].cumsum()

results['pct_true'] = results['total_true'] / results['total_statements']
