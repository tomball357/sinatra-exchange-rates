require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require 'httparty'
require 'json'



require 'sinatra'
require 'httparty'
require 'json'

BASE_URL = "https://api.exchangerate.host"

get '/' do
  "Welcome to the Currency Converter API!"
end

get '/currencies' do
  response = HTTParty.get("#{BASE_URL}/list")
  data = JSON.parse(response.body)
  data["currencies"].to_json
end

get '/convert/:from/:to' do
  from_currency = params[:from]
  to_currency = params[:to]
  response = HTTParty.get("#{BASE_URL}/convert", query: { from: from_currency, to: to_currency, amount: 1 })
  data = JSON.parse(response.body)
  rate = data["result"]
  { from: from_currency, to: to_currency, rate: rate }.to_json
end
