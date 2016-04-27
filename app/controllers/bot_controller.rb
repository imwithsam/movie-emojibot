require 'net/http'

class BotController < ApplicationController
  def say
    movie = URI.encode(params[:movie])
    url = URI.parse("http://www.omdbapi.com/?t=#{movie}&y=&plot=full&r=json")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP::start(url.host, url.port) { | http |
      http.request(req)
    }
    @plot = JSON.parse(res.body)['Plot']
    plot_words = @plot.split(/\W+/)
    @emojis = plot_words.map { |word| emojify(word) }
  end

  private

  def emojify(word)
    file = File.read("#{Rails.root}/app/assets/javascripts/emojis.json")
    json = JSON.parse(file)
    emoji1 = json.select do |emoji, _|
      emoji == word.downcase || emoji == word.singularize.downcase
    end
    emoji2 = json.select do |_, values|
      values['keywords'].include?(word.downcase) || values['keywords'].include?(word.singularize.downcase)
    end

    if !emoji1.empty?
      emoji1.values[0]['char']
    elsif !emoji2.empty?
      emoji2.to_a.sample[1]['char']
    else
      word
    end
  end
end
