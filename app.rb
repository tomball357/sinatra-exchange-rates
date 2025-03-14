require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require 'httparty'
require 'json'


BASE_URL = "https://api.exchangerate.host"
API_KEY = ENV['exchange_key']

# Fetch currency list once and store it to minimize API calls
def fetch_currencies
  response = HTTParty.get("#{BASE_URL}/list", query: { access_key: API_KEY })

  if response.success?
    data = JSON.parse(response.body)
    return data["currencies"] || {}  # Extract currency symbols
  else
    puts "Error fetching currencies: #{response.code}"
    return {}
  end
end

CURRENCIES = fetch_currencies

# Root route - Displays all available currencies
get '/' do
  erb :homepage, locals: { currencies: CURRENCIES }
end

# Currency symbol page - Displays conversion options for a specific currency
get '/:currency' do
  currency = params[:currency].upcase
  halt 404 unless CURRENCIES.key?(currency)  # Ensure valid currency
  erb :currency, locals: { currency: currency, currencies: CURRENCIES }
end

# Currency conversion page - Displays conversion rate between two currencies
get '/:from_currency/:to_currency' do
  from_currency = params[:from_currency].upcase
  to_currency = params[:to_currency].upcase

  halt 404 unless CURRENCIES.key?(from_currency) && CURRENCIES.key?(to_currency)

  response = HTTParty.get("#{BASE_URL}/convert", query: { access_key: API_KEY, from: from_currency, to: to_currency, amount: 1 })
  
  if response.success?
    data = JSON.parse(response.body)
    rate = data["result"]
  else
    rate = "Unavailable"
  end

  erb :conversion, locals: { from_currency: from_currency, to_currency: to_currency, rate: rate }
end
