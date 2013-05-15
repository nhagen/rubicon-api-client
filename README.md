rubicon-api-client
==================

A simple, unofficial ruby api client for accessing the Rubicon Project's reporting api. Many things have not been
implemented, and error checking is minimal.

Currently only partially implements seller API. No reason why it couldn't support demand! Pull requests welcome.

Based on public api documentation provided here:

http://kb.rubiconproject.com/index.php/Seller/Seller_API_Specification

http://kb.rubiconproject.com/index.php/Demand/Demand_API_Specification

Default values and behaviors are taken from the specifications.

### Installation
```
$ gem install rubicon-api-client
```

### Usage
```ruby
# rubicon_report.rb
require 'rubicon-api-client'
require 'pp'
require 'crack'

API_ACCOUNT = 'API ACCOUNT ID HERE'
API_KEY     = 'API KEY HERE'
API_SECRET  = 'API SECRET HERE'

client = RubiconApiClient::Seller.new API_ACCOUNT, API_KEY, API_SECRET

# Define dimensions according to api specs
dims = ['date','site','ad_size']
measures= ['revenue','rcpm']

# Lets look at the pretty print hash output after parsing the XML returned by the api
pp Crack::XML.parse client.ad_hoc_performance_report(dims,measures,nil,'last week')
```

```
$ ruby rubicon_report.rb
{"performance_groups"=>
  {"group"=>
    [{"site_id"=>"12345",
      "site_name"=>"RandomSite",
      "rows"=>
       [{"date"=>"2013-05-05", "revenue"=>"55.7654", "rcpm"=>"0.01"},
        {"date"=>"2013-05-06", "revenue"=>"57.4649", "rcpm"=>"0.02"},
        {"date"=>"2013-05-07", "revenue"=>"56.4471", "rcpm"=>"0.01"},
        {"date"=>"2013-05-08", "revenue"=>"72.8282", "rcpm"=>"0.02"},
        {"date"=>"2013-05-09", "revenue"=>"55.9902", "rcpm"=>"0.01"},
        {"date"=>"2013-05-10", "revenue"=>"75.5263", "rcpm"=>"0.11"},
        {"date"=>"2013-05-11", "revenue"=>"41.8078", "rcpm"=>"0.99"}]}]}}
```

### Examples

The RubiconApiClient module currently contains 2 classes. The first is a base client class
with methods for interacting with the API. If you know what API path you're going to call,
you can call it directly like this:

```ruby
require 'rubicon-api-client'
require 'pp'

API_ACCOUNT = 'API ACCOUNT ID HERE'
API_KEY     = 'API KEY HERE'
API_SECRET  = 'API SECRET HERE'

path = '/seller/api/ips/v2/etc......'
client = RubiconApiClient::RubiconClient.new API_ACCOUNT, API_KEY, API_SECRET
pp client.execute(path)
```
This will return the expected results of that API service call in XML.



```ruby
require 'rubicon-api-client'
require 'pp'

API_ACCOUNT = 'API ACCOUNT ID HERE'
API_KEY     = 'API KEY HERE'
API_SECRET  = 'API SECRET HERE'

client = RubiconApiCient::Seller.new API_ACCOUNT,API_KEY, API_SECRET, :json
response = client.zone_performance_report
```
This will return a zone report for yesterday's data, using all sites, as JSON.


### Documentation

#### RubiconApiClient::RubiconClient

* **initialize(account id, key,  secret, format)**
    * **account id** - <_string_> - Rubicon account ID
    * **key** - <_string_> - API key shared between Rubicon and Client. Used as username in authentication
    * **secret** - <_string_> - API secret shared between Rubicon and Client. Used as password in authentication
    * **format** - <_symbol_> - Type of data format to request
        * _:xml, :json, :csv_
* **execute(path)**
    * **path** - <_string_> - URL to send API request to.
        - Example: `/seller/api/ips/v1/reports/zone/performance/123456 `

#### RubiconApiClient::Seller < RubiconApiClient::RubiconClient
* **zone_performance_report(site_ids, *date_range)**
    * **site_ids** - <_array_> - Set of site ids to pull data for
    * **\*date_range** - <_strings_> - A string describing a time period, or two strings representing the start and end dates respectively. Valid input includes:
        * `zone_performance_report(nil, 'last week')`
        * `zone_performance_report(nil, 'yesterday', 'August 12, 2012', '2012-08-14')`
    * **ad_hoc_performance_reports(dimensions, measures, currency, *date_range)**
        * **dimensions** - <_array_> - Dimensions to retrieve data by
            * _'date', 'ad_size', 'site', 'zone', 'country', 'keyword', 'campaign', 'campaign_relationship', 'partner', 'agency'_
        * **meaures** - <_array_> - Metrics to pull
            * _'paid_impressions', 'total_impressions', 'revenue', 'ecpm', 'rcpm', 'fill_rate'_
        * **currency** - <_string_> - Currency abbreviation describing currency to display data in
        * **date_range** - <_strings_> - A string describing time period, or two strings representing the start and end dates respetively.
