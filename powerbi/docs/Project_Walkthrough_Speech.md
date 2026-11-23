# 25-Minute Speech: Banking Analytics & Risk Intelligence
### Advanced Dashboard Features & Business Intelligence Reporting
**Prepared for: Priyal Sompura**

---

> **Timing Guide:** ~130–140 words per minute. This speech is approximately 3,200 words — comfortably 23–25 minutes with natural pauses.

---

## SLIDE 1 — Title Slide (~1 minute)

Good [morning/afternoon], everyone.

Today, I'm presenting the comprehensive end-to-end implementation of Banking Analytics and Risk Intelligence. What you're about to see is not just a collection of charts — it's a full-stack business intelligence solution built from the ground up, using PostgreSQL, Power BI, DAX, and advanced data modeling.

This presentation focuses on the dashboards themselves — four interactive, production-grade dashboards designed specifically for banking professionals. Each one tells a different story about the portfolio, and together, they give leadership the complete picture they need to make confident, data-driven decisions.

So let's get into it.

---

## SLIDE 2 — Data Architecture & Pipeline Foundation Recap (~2.5 minutes)

Before we dive into the dashboards, let me quickly take you through the foundation we built during the data engineering and modeling phases — because none of what you'll see today would exist without that groundwork.

**Week 1** was all about understanding the banking domain. We explored core concepts like loan lifecycle, NPA — Non-Performing Assets — DPD, Days Past Due, and PAR, Portfolio at Risk. We examined five data tables, documented column types and null rates, and identified the three KPIs that would become the backbone of this project: PAR, NPA Rate, and Collection Efficiency. We also planned out a Star Schema architecture, with the total loan table as our fact table and four dimension tables mapped around it.

**Week 2** brought the environment to life. We set up PostgreSQL, created and ingested five raw tables from CSV files, and then cleaned the data rigorously — handling nulls, fixing type mismatches, removing duplicates. The result was a clean staging layer: five staging tables that formed a solid, trustworthy data foundation.

**Week 3** was about automation. We built a modular Python ETL package with separate extract, transform, and load modules, and deployed an Apache Airflow DAG — the loan portfolio ETL — running on a daily schedule inside a Docker environment. We validated four successful daily runs and confirmed record counts, PK uniqueness, and referential integrity were all intact.

And **Week 4** connected everything to Power BI. Using the native PostgreSQL connector, we modeled five analytical views and built ten production-grade KPIs as reusable DAX measures. The first two dashboards — Portfolio Health and Repayment & Recovery — were built and validated.

That brings us to today: Project, where we complete the dashboard suite and build out the full Business Intelligence reporting structure.

---

## SLIDE 3 — Project Objectives (~1 minute)

This week had a focused set of objectives. We were building out the remaining two dashboards — the Risk Dashboard and the Customer Dashboard. On top of that, we added interactive filters, trend analysis, and cross-visual interactions. We also optimized the Power BI data model, designed the navigation experience, and built out the full BI reporting structure — from raw CSV files all the way through to business insights.

Let me now walk you through each dashboard in detail.

---

## SLIDE 4 — Loan Portfolio Dashboard (~3 minutes)

The first dashboard is the **Loan Portfolio Dashboard**, and it is the anchor of the entire report.

Its objective is simple but powerful: give any stakeholder — whether that's a branch manager, a portfolio analyst, or a senior executive — a real-time view of the health of the loan book. This means tracking disbursements, outstanding exposure, and loan status, all in one place, to support proactive portfolio management.

The dashboard is built around five KPIs displayed as headline cards at the top of the page:
- **Loan Accounts** — the total number of active records in the portfolio
- **Disbursed Amount** — the total capital that has been lent out
- **Outstanding Portfolio** — how much remains to be collected
- **Active Loans** — loans that are currently running
- **Closed Loans** — loans that have been fully repaid or resolved

Below the KPI cards, we have a rich set of visuals. A **Line Chart** tracks how disbursements have moved over time — giving us the growth story of the portfolio. A **Bar Chart** breaks down the portfolio by branch, so we can immediately see which locations are carrying the most exposure. A **Donut Chart** gives us a visual split of loan statuses — active, closed, written off — in one clean view. And a **Treemap** and **Waterfall Chart** round out the page by showing portfolio composition and outstanding balance movement in an intuitive, executive-friendly format.

The business insights from this dashboard are clear:
- **Agriculture** holds the highest portfolio share, which means it deserves special monitoring from a risk and concentration standpoint.
- Branch-wise comparison is immediately visible — no guesswork needed.
- The outstanding amount is well-distributed, which is a sign of a healthy, diversified portfolio.
- And the loan status overview gives leadership a one-glance health check of the entire book.

---

## SLIDE 5 — Repayment Dashboard (~3 minutes)

The second dashboard is the **Repayment Dashboard**, built specifically to equip collections teams with the intelligence they need to do their jobs effectively.

The objective here is to monitor recovery rates, track interest collection, and understand where write-offs are concentrated — by loan purpose, by segment, and over time.

The five KPIs on this page are:
- **Repaid Amount** — the total principal that has been returned
- **Recovery Rate** — the percentage of outstanding loans that have been successfully collected
- **Interest Collection** — how much interest income has been realized
- **PAR Rate** — Portfolio at Risk Rate, which flags the percentage of the portfolio showing signs of stress
- **Written Off Amount** — the total value of loans that have been declared unrecoverable

The visuals on this page tell a compelling story. The **Monthly Repayment Trend** is a line chart showing how collections perform month by month — and we can see consistent, stable performance. The **Recovery Rate by Loan Size** visual breaks down performance across small, medium, and large loan buckets, so we can see whether collection effectiveness varies with loan size. The **Written Off Analysis** isolates those accounts, helping collections leadership understand where losses are concentrated. The **Recovery Performance Table** is a drill-through table providing loan-level detail for any account. And the **Donut Chart** gives a quick visual summary of recovered versus outstanding amounts.

The headline insight from this dashboard is a remarkable one: **a recovery rate of 98.9%**. That is a genuinely strong result. It means that across the entire portfolio, nearly every rupee lent has been recovered. Written-off amounts, while present, are concentrated in a small number of segments — meaning this is a manageable, targeted problem rather than a systemic one. And repayment trends are steady, which gives the collections team confidence in their forecasting.

---

## SLIDE 6 — Risk Dashboard (~3 minutes)

The third dashboard is the **Risk Dashboard**, and this one is especially important for senior risk officers and portfolio managers.

Its objective is to surface risk concentration — to identify where in the portfolio loans are most likely to default, where exposure is highest, and what the residual risk looks like across different segments.

The KPIs on this page are:
- **Loans at Risk** — the number of ac  counts showing DPD or PAR triggers
- **Risk Exposure** — the outstanding value of those at-risk accounts
- **Average Loan Cycle** — how mature the average loan in the portfolio is
- **Residual Exposure** — the remaining principal on flagged accounts
- **Written Off Rate** — the percentage of the portfolio that has been written off

The visual suite here is carefully chosen for risk analysis. The **Loan Age Trend** chart plots how loans are distributed across their lifecycle — this is critical because loans in the early stages of a cycle often carry higher risk. The **Risk by Loan Purpose** visual breaks down risk concentration by category — agriculture, personal, business, and so on — giving us clear segmentation. The **Risk Distribution** chart shows the shape of risk across the portfolio: whether it's evenly spread or concentrated in a few accounts. The **Loan at Risk Table** is a sortable, filterable table listing every flagged account — this is the tool that collections officers use for daily monitoring. And the **Amount Segment Analysis** shows whether large-ticket or small-ticket loans are carrying more risk.

The insights here are important to understand clearly:
- **Agriculture once again carries the highest risk concentration.** Given that it also holds the largest portfolio share, this is a segment that requires dedicated monitoring protocols.
- **High outstanding exposure exists in early loan cycles.** This makes sense — newer loans haven't had the time to repay down the principal — but it also means the risk book is forward-looking.
- **Risk clusters by loan purpose are clearly identifiable.** This allows the risk team to apply targeted interventions rather than broad policies.
- And the **Loan at Risk Table** ensures that no individual account slips through the cracks.

---

## SLIDE 7 — Customer Dashboard (~3 minutes)

The fourth and final dashboard is the **Customer Dashboard**, which shifts our lens from the loans themselves to the people and groups behind them.

The objective here is to profile the customer base — understanding customer status, segment composition, and group dynamics — to support relationship management and customer retention strategy.

The KPIs are:
- **Total Customers** — the complete size of the customer base
- **Active Customers** — those currently holding a live loan
- **Active Groups** — the number of group-lending units currently active
- **Customer Retention** — the percentage of customers who have returned for subsequent loans
- **Average Tenure** — how long the average customer has been with the institution

The visuals on this page include:
- A **Customer Status** breakdown showing the distribution of active, closed, and dormant customers
- A **Customer Segment** view breaking down customers by lending category
- A **Customer Type** breakdown distinguishing between individual and group borrowers
- A **Group Composition** chart showing the makeup of active groups
- And a **Customer Summary** table that gives branch-level detail across all customer metrics

The insights from this dashboard are strategically valuable. The majority of the customer base consists of **established customers** — those who have taken and repaid at least one prior loan. This is a signal of institutional trust and loyalty. Clear segmentation by branch highlights where growth opportunities exist. Group composition is evenly distributed across statuses, which speaks to the health of the group-lending program. And the branch-wise customer view gives relationship managers the data they need to manage their portfolios effectively.

---

## SLIDE 8 — Interactive Dashboard Features (~2 minutes)

Now let's talk about what makes these dashboards more than just static reports — the interactivity.

Power BI is a powerful platform precisely because it allows users to explore data on their own terms, and we've built that capability in at every level.

The report features **Sidebar Navigation** — a persistent panel that allows you to jump between any of the four dashboards with a single click. There's no need to use the report browser or navigate through pages manually.

Every page is built with **Cross-Visual Interaction** at its core. When you click on a bar in the branch chart, every other visual on the page — the KPI cards, the donut chart, the trend line — filters to reflect only that branch. This is how self-service analysis actually works in practice.

There's a dedicated **Filter Panel** on every page, accessible via a filter button. This gives users a formal, structured way to apply filters — separate from clicking on visuals.

The **KPI Cards** are always anchored at the top of every page. These give any viewer — from a data analyst to a CEO — the most important numbers immediately, without needing to dig into the charts.

All charts are **hover and click enabled**, and the tables are **sortable**, so users can drill down to exactly the level of detail they need.

The interaction workflow is intuitive: you select a filter, the charts update, and the KPIs refresh — all in real time.

---

## SLIDE 9 — Interactive Filters (~1.5 minutes)

Let me be specific about the filters available in the dashboard.

Users can filter by:
- **Branch** — to isolate a specific office or region
- **Loan Purpose** — to focus on agriculture, personal, business, and so on
- **Loan Status** — to look only at active, closed, or written-off accounts
- **Customer Type** — individual versus group borrowers
- **Amount Segment** — small, medium, or large ticket loans
- **Date** — where date fields are available

Filtering supports both **single-select** — choosing one value at a time — and **multi-select** — combining multiple values for a broader view. Cross-filtering from visual clicks works alongside these panel filters, and all filters reset cleanly, so users can move quickly between comparison scenarios without manual cleanup.

---

## SLIDE 10 — Trend Analysis (~1.5 minutes)

One of the most powerful capabilities in this dashboard suite is the trend analysis built across every page.

We track four key trends:

**Monthly Disbursement Trend** — showing how the volume of new loans has grown or shifted over time. This is the portfolio growth story.

**Monthly Repayment Trend** — showing how collections perform month by month. Consistent repayment curves here signal a healthy, predictable collections process.

**Outstanding Portfolio Trend** — tracking how total exposure changes as loans mature and are repaid. A declining outstanding balance as the loan book ages is exactly what healthy portfolio dynamics look like.

**Risk Trend** — tracking the volume and value of at-risk loans over time. An uptick in this trend is an early warning signal that should trigger a management review.

Together, these four trends give stakeholders both a backward-looking view — what has happened — and a forward-looking posture — what to watch for.

---

## SLIDE 11 — Dashboard Optimization (~1.5 minutes)

Building dashboards that look good is only half the job. The other half is ensuring they perform well and are maintainable over time.

For this project, we followed a strict set of Power BI best practices.

The data model is built on a **Star Schema** — the fact table surrounded by clean dimension tables — which is the gold standard for analytical performance. Relationships across the model are all **one-to-many**, which ensures that DAX calculations behave predictably. Every KPI is built as a **DAX Measure** — reusable, auditable, and easy to update when business definitions change.

On the visual design side, we applied a **consistent navy, blue, and white banking theme** across all four pages. This isn't just aesthetic — it reduces cognitive load for users who move between dashboards. Visuals are kept minimal — only the charts and tables that directly support the KPIs are included. Layouts are grouped logically by topic, and KPI Cards are always at the top. The result is a report that renders quickly, reads cleanly, and is built for non-technical stakeholders.

---

## SLIDE 12 — Dashboard Navigation (~1 minute)

Navigation was designed with simplicity in mind. The four dashboards — Loan Portfolio, Repayment, Risk, and Customer — are connected by a persistent sidebar that appears on every page. One click moves you between any two dashboards. The layout grammar is identical across all four pages, so users always know where the KPIs are, where the filters are, and where the detail tables are. This consistency dramatically reduces the learning curve for new users.

---

## SLIDE 13 — BI Reporting Structure (~1.5 minutes)

Let me now zoom out and show you how this entire solution fits together as an end-to-end Business Intelligence pipeline.

It starts with **raw CSV files** — loan data, customer data, branch data — ingested into **PostgreSQL**. From there, SQL views are built to clean, aggregate, and prepare the data. Those views are pulled into **Power BI**, where **DAX Measures** are written to define every KPI precisely. Those measures power the **four dashboards**, and the dashboards deliver **Business Insights** that drive decisions.

The six stages are: Data Collection → Data Cleaning → Data Modeling → Visualization → Reporting → Decision Making.

This is a complete, production-grade BI pipeline. Every layer is documented, every transformation is auditable, and every KPI is traceable back to the source data.

---

## SLIDE 14 — Dashboard Best Practices (~1 minute)

Before I get to the business insights, let me quickly summarize the design principles that guided this entire dashboard suite.

Everything was built for **executive-level, at-a-glance decision making** — not for data scientists. The color palette is consistent and professional. The interactivity is intuitive. Every metric ties directly to a business question — there are no vanity metrics here. Each dashboard ends with a clear, actionable takeaway. And the sidebar navigation keeps every page one click away.

These aren't just aesthetic choices — they're what separates a dashboard that gets used from one that gets ignored.

---

## SLIDE 15 — Business Insights (~2 minutes)

Now for the most important slide: what do all of these dashboards actually tell us about the business?

**Portfolio Insights:** Agriculture drives the largest share of disbursement. Branch-wise portfolio share is clearly distinguishable. And the loan status mix is dominated by closed accounts — which is a healthy sign, showing that the institution is successfully cycling loans through to completion.

**Repayment Insights:** Recovery rate sits at 98.9% — an outstanding result by any industry benchmark. Written-off amounts are concentrated in a few categories, making them manageable. And the repayment trend reflects steady, predictable monthly collection.

**Risk Insights:** Agriculture carries the highest risk concentration, which warrants focused attention given its portfolio share. Risk exposure is heavily weighted toward early loan cycles. And a small set of accounts holds the majority of residual exposure — meaning targeted intervention can have outsized impact.

**Customer Insights:** Established customers make up the majority of the base, reflecting strong retention. Segmentation highlights growth opportunities in specific branches and categories. Group composition is evenly split, showing a balanced lending program.

The **overall conclusion**: the portfolio is healthy, recovery is strong, risk is concentrated and trackable, and the customer base is stable. This is a business that can make confident, data-driven decisions.

---

## SLIDE 16 — Key Takeaways (~1 minute)

Let me bring it all home with the six key takeaways from this project:

1. **Portfolio Monitoring** — We now have real-time visibility into disbursement and outstanding exposure.
2. **Interactive Analysis** — Cross-filtering enables fast, self-service exploration for any stakeholder.
3. **Risk Monitoring** — Risk concentration is surfaced early, enabling proactive action before defaults occur.
4. **Customer Analysis** — Segment and tenure visibility supports a data-driven retention strategy.
5. **Business Reporting** — A single, consistent reporting layer now serves all stakeholders across the organization.
6. **Power BI Dashboard Development** — A complete four-page banking dashboard has been built end-to-end.

---

## SLIDE 17 — Closing (~30 seconds)

And with that, we've reached the end of this five-week journey — from raw CSV files and PostgreSQL tables, all the way through to a full-stack, interactive banking intelligence platform.

The dashboards are live. The pipeline is automated. The insights are actionable.

Thank you for your time and attention. I'm happy to take any questions.

---

*End of Speech — Estimated delivery time: 23–25 minutes*

