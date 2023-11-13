require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    alphabet = ('A'..'Z')
    alphabet_array = alphabet.to_a
    @letters = alphabet_array.sample(10)
  end

  def score
    # 1. grab the letters from the params
    @letters = params[:letters].downcase.split
    # 2. get the submitted word from the params
    @attempt = params[:attempt].downcase


    # 5. compute the score and display it
    if is_english_word? && is_valid_word?
      @score = @attempt.length.fdiv(@letters.length) * 100
    else
      @score = 0
    end
    session[:score] = session[:score].present? ? session[:score] + @score : @score
    @current_score = session[:score]
    @message = create_message
  end

  private

  # {
  #   "found": false,
  #   "word": "hellow",
  #   "error": "word not found"
  # }
  def is_english_word?
    # 4. check if the submitted word is an english word
    url = "https://wagon-dictionary.herokuapp.com/#{@attempt}"
    api_content = URI.open(url).read
    response = JSON.parse(api_content)
    response["found"]
  end

  def is_valid_word?
    # 3. compare the letters with the submitted word
    @attempt.chars.all? do |char|
      @attempt.count(char) <= @letters.count(char)
    end
  end

  def create_message
    if is_english_word? && is_valid_word?
      "Congrats #{@attempt} is a valid word"
    elsif is_english_word? && !is_valid_word?
      "Sorry but #{@attempt} can't be built out of #{@letters}"
    elsif !is_english_word? && is_valid_word?
      "Sorry but #{@attempt} does not seem to be a valid English word..."
    else
      "Sorry but #{@attempt} can't be built out of #{@letters}"
    end
  end
end
