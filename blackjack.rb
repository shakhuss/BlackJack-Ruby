class Card
  attr_accessor :suit, :name, :value

  def initialize(suit, name, value)
    @suit, @name, @value = suit, name, value
  end
end

class Deck
  attr_accessor :playable_cards
  SUITS = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1].sample} # Due to the 2 values present, sample method is used to pick random value from the two

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    @playable_cards = []
    SUITS.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

end


class Player
  attr_accessor :player_hand, :player_total

  def initialize
    @player_hand = Hand.new; # Creates an array for the hand
    @player_total = 0; # Sets total to 0
  end

  def hit(gamedeck) # To hit via the gamedeck
    @player_hand.cards.push(gamedeck.game_deck.deal_card) # Pushes a card from the gamedeck to the hand
    @player_total = @player_hand.cards.inject(0) {|sum, i| sum + i.value} # Calculates the total of the hand
    if @player_total > 21
      puts "Player Loses due to Bust with total of #{player_total}" # Instant Bust
    elsif @player_total == 21
      puts "Player Wins due to BlackJack" # Instant BlackJack
    end
  end
end




class GameDeck
  attr_accessor :game_deck

  def initialize
    @game_deck = Deck.new # Creates new array for the deck
  end

  def deal_player(player) # Deals two cards to the player
    x = 1
    y = 2
    while x <= y
      card = @game_deck.deal_card
      player.player_hand.cards.push(card)  
      x += 1
    end
    player.player_total = player.player_hand.cards.inject(0) {|sum, i| sum + i.value}
  end
  
  def deal_dealer(dealer) # Deals two cards to the dealer
    x = 1
    y = 2
    while x <= y
      card = @game_deck.deal_card
      dealer.dealer_hand.cards.push(card)  
      x += 1
    end  
  end
end


class Dealer
  attr_accessor :dealer_hand, :dealer_points

  def initialize
    @dealer_hand = Hand.new # Array for the dealer's hand
  end

  def dealer_turn(player, gamedeck) # Takes in the players total and the gamedeck as arguments
    @dealer_points = @dealer_hand.cards.inject(0) {|sum, i| sum + i.value}
    puts "Dealer has #{dealer_points}"
    if player.player_total > 21
      puts "Dealer Wins due to Player Bust with total of #{dealer_points}"
    elsif player.player_total == 21
      puts "Player Wins due to BlackJack"
    else 
      while @dealer_points < 17 do # While loop to maintain dealer's hand at 17 or above
        @dealer_hand.cards.push(gamedeck.game_deck.deal_card)
        @dealer_points = @dealer_hand.cards.inject(0) {|sum, i| sum + i.value}
        puts "Dealer hits and has total of #{dealer_points}"
      end
      if @dealer_points == 21
          puts "Dealer Wins due to BlackJack with total of #{dealer_points}"
        elsif @dealer_points > 21 
          puts "Dealer Loses due to Bust with total of #{dealer_points}", "Player Wins with total of #{player.player_total}"
        elsif @dealer_points > player.player_total
          puts "Dealer Wins due to Higher Total with total of #{dealer_points}"
        elsif @dealer_points < player.player_total
          puts "Player Wins due to Higher Total with total of #{player.player_total}", "Dealer has total of #{dealer_points}"
        elsif @dealer_points == player.player_total
          puts "Tie Game with both total of #{dealer_points}"    
        end
      
    end
  end
end     


require 'test/unit'

class CardTest < Test::Unit::TestCase
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end
  
  def test_card_suit_is_correct
    assert_equal @card.suit, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end
  def test_card_value_is_correct
    assert_equal @card.value, 10
  end
end

class DeckTest < Test::Unit::TestCase
  def setup
    @deck = Deck.new
  end
  
  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end
  
  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    refute(@deck.playable_cards.include?(card)) # Use of refute method since assert is expecting 'true' yet it is false. Refute passes since the argument is false
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
end



begin
  cpu = GameDeck.new
  player = Player.new
  dealer = Dealer.new
  puts "Ready to Play BlackJack? Enter y for Yes or n for No"
  ready = gets.chomp
  if ready === 'y'
    cpu.deal_player(player)
    cpu.deal_dealer(dealer)
    puts "You have #{player.player_hand.cards[0].value} and #{player.player_hand.cards[1].value}"
    puts "Dealer has #{dealer.dealer_hand.cards[0].value} and #{dealer.dealer_hand.cards[1].value}"
    puts "Hit? Y or N"
    hit = gets.chomp
    if hit === 'y'
      player.hit(cpu)
      puts "You have #{player.player_total}"
      dealer.dealer_turn(player, cpu)
    else
      dealer.dealer_turn(player, cpu)
  
    end
  end


end