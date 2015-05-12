# nouns: player, deck, card,
# behavior:
# player
# - show cards
# - calculate_sum
# - hit or stay
# deck
# - new_deck
# - shuffle cards
# - deal card
# card
# - display card
# game engine
# - compara sum
# - player turn

class Card
  SUITS = %w(Diamonds Clubs Hearts Spades)
  CARDS = %w(A 2 3 4 5 6 7 8 9 10 J Q K)

  attr_reader :name, :suit

  def initialize(suit, name)
    @name = name
    @suit = suit
  end

  def to_s
    message = "+" + "-" * 25 + "+\n"
    message += "|" + "Suit:#{suit}, Card:#{name}".center(25) + "|"
    message += " <= MASK CARD" if suit == 'X' && name == 'X'
    message += "\n+" + "-" * 25 + "+\n"
  end
end

class Deck
  attr_accessor :cards, :num_of_decks

  def initialize(n)
    @cards = []
    @num_of_decks = n
  end

  def new!
    cards.clear
    Card::SUITS.product(Card::CARDS).each do |suit, card|
      self.cards << Card.new(suit, card)
    end

    self.cards *= num_of_decks
  end

  def shuffle!
    cards.shuffle!
  end

  def deal_card(player)
    new_card = cards.pop
    player.cards << new_card
    puts "Dealing \n#{new_card} to #{player.name}." if player.cards.size > 2
  end
end

class Player
  attr_reader :name
  attr_accessor :cards, :mask_card

  BLACKJACK = 21
  ACE = 'A'

  def initialize(name)
    @name = name
    @cards = []
    @mask_card = []
  end

  def display_cards(show_mask_card = false)
    puts "#{name}'s cards:"
    cards.each do |card|
      card = Card.new('X', 'X') if !show_mask_card && mask_card.last == card
      puts card
    end
    puts ""
  end

  def cards_sum
    sum = 0
    cards.each do |card|
      if card.name == ACE
        sum += 11
      elsif %w(J Q K).include?(card.name)
        sum += 10
      else
        sum += card.name.to_i
      end
    end

    cards.select{ |card| card.name == ACE }.count.times.each do
      sum -= 10 if sum > BLACKJACK
    end

    sum
  end

  def hit_blackjack?
    cards_sum == BLACKJACK
  end

  def busted?
    cards_sum > BLACKJACK
  end

  def display_winning_message
    puts "#{name} won!"
  end

  def display_cards_sum
    puts "Sum of #{name}'s cards is #{cards_sum}."
  end
end

class Gambler < Player
  def hit?
    begin
      puts "Hit or Stay?(h/s)"
      answer = gets.chomp
    end until %w(h s).include?(answer)

    answer == 'h'
  end
end

class Dealer < Player
  def hit?
    cards_sum >= 17 ? false : true
  end
end

class Game
  attr_reader :gambler, :dealer, :deck
  DEALER_NAME = 'Dealer'

  def initialize
    @gambler = Gambler.new(get_user_name)
    @dealer = Dealer.new(DEALER_NAME)
    @deck = Deck.new(num_of_decks = 4)
  end

  def get_user_name
    puts "What's your name?"
    answer = gets.chomp.downcase.capitalize
  end

  def deal_two_cards
    2.times do
      deck.deal_card(gambler)
      deck.deal_card(dealer)
    end

    dealer.mask_card << dealer.cards.last
  end

  def clear_players_cards
    gambler.cards.clear
    gambler.mask_card.clear
    dealer.cards.clear
    dealer.mask_card.clear
  end

  def display_board(show_mask_card)
    system "clear"
    gambler.display_cards
    dealer.display_cards(show_mask_card)
  end

  def turn(player)
    show_mask_card = if player.name == DEALER_NAME
                       true
                     else
                       false
                     end

    display_board(show_mask_card)
    check_winner(player)

    while player.hit?
      deck.deal_card(player)
      sleep 1 if player.name == DEALER_NAME
      check_winner(player)
    end

    puts "#{player.name} choose to stay."
    sleep 1 if player.name == DEALER_NAME
  end

  def check_winner(player)
    if player.busted?
      puts "#{player.name} busted, #{player.name} lose!"
      once_again?
    elsif player.hit_blackjack?
      puts "#{player.name} hit blackjack,#{player.name} won!"
      once_again?
    end
  end

  def compare_both_sum
    display_board(show_mask_card = true)
    gambler.display_cards_sum
    dealer.display_cards_sum

    if gambler.cards_sum > dealer.cards_sum
      gambler.display_winning_message
    elsif gambler.cards_sum < dealer.cards_sum
      dealer.display_winning_message
    else
      puts "It's a tie!"
    end

    once_again?
  end

  def prepare_deck
    deck.new!
    deck.shuffle!
  end

  def run
    clear_players_cards
    prepare_deck
    deal_two_cards
    turn(gambler)
    turn(dealer)
    compare_both_sum
  end

  def once_again?
    begin
      puts "#{gambler.name}, once again(y/n)?"
      answer = gets.chomp.downcase[0]
    end until %w(y n).include?(answer)

    answer == 'y' ? run : exit
  end
end

system "clear"
Game.new.run
