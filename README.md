# ShinyDaggboard
Data aggregator and dashboard using shiny and R

This is a sample Shiny application demonstrating basic functionality required to aggregate and user account data for review in a tabular format.
A further implementaion of this app can be to use the data to generate graphical insights to show key higlights of the review.

Note that this application has it's own databseas the source of data. This is highly valuable when running in a regulaed environment where installation of software/libraries is prohibited. 
This requires a powerful host to keep the data loaded while running the application and can be a cause for concern for large amount of user accounts.
Although this can be valuable in a restricted enviroment, an actual database like MongoDB or MySQl is recommended which can be accessed through R connectors. This also alllows for the data to be accessible through external endpoints which can help in data aggregation and distribution.
