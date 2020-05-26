require 'elasticsearch'
require 'base64'

client = Elasticsearch::Client.new url: 'http://localhost:9200', log: true

pdf_text = File.read("pcm_ieee_micro10.pdf", :encoding => 'utf-8')
pdf_base64 = Base64.encode64(pdf_text)

#client.delete index: "pdf", type: "_doc", id: 42
client.index index: "pdf", type: "_doc", id: 42, body: {data: pdf_base64} 
