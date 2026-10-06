# Executive Summary

This project analyses Bluebikes journey data across Greater Boston from **2016 to 2019** to understand usage growth, user behaviour, station demand, operational imbalance and weather-related demand patterns.

A staged workflow was used:

**SQL → Python → Tableau**

SQL combined and validated the annual journey tables, Python prepared external weather and station-flow enrichment, and Tableau presented the results through four interactive dashboards.

## Headline results

- **6.83M cleaned journeys**
- Annual journeys increased from approximately **1.24M in 2016** to **2.52M in 2019**
- Overall growth: **104.1%**
- Subscribers represent **80.6%** of journeys
- Subscriber median journey: **~10.1 minutes**
- Customer median journey: **~21.2 minutes**
- Strong Subscriber peaks occur around **08:00 and 17:00**
- Demand is highly seasonal
- Station pressure is geographically concentrated
- Directional flow identifies clear rebalancing candidates
- Heavy rain and snowfall are associated with lower daily demand

## Operational conclusion

The strongest opportunities are targeted rather than system-wide.

Bluebikes should prioritise:

- proactive rebalancing around persistent station imbalance
- station-capacity review where demand is high relative to dock count
- operational planning around weekday peaks
- weather-aware staffing, redistribution and maintenance planning

The core message is to target the **right stations, at the right times, under the right conditions**.
