require 'elasticsearch'
require 'base64'

client = Elasticsearch::Client.new url: 'http://localhost:9200', log: true

response = client.get index: "pdf", type: "_doc", id: 42
data = response["_source"]["data"]

File.write("/home/downloads/downloaded.pdf", Base64.decode64(data))
