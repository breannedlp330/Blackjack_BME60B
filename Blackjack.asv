clear; clc;
%% Ready, Set, Start! 

% asking for the number of players
nPlayers = input("How many players? ");  % numeric input

% initialize deck 
myDeck= initDeck();

%% Initialize Players

myPlayers = struct(); % create array for players
myPlayers.name = cell(nPlayers, 1); % name the first column of myPlayers "name"

% name each player
for i = 1:nPlayers 
    myPlayers.name{i} = input("Player "+ i + " name: ", "s");
end 

myPlayers.hand = cell(nPlayers, 1); % each will hold a table of cards
myPlayers.vals = zeros(nPlayers, 1); % numeric hand value per player
myPlayers.inRound = true(nPlayers, 1); % still playing this round (not busted)

%% Main loop 

playAgain = "y";
while playAgain == "y" % as long as players input y to continue playing

    playingDeck = shuffleDeck(myDeck); % shuffled deck

    % Header at the beginning of round with number of players and deck size
    disp("----- NEW ROUND -----")
    disp("Players: " + nPlayers)
    disp("Deck size at start: " + height(playingDeck))

    % Reset inRound state
    myPlayers.inRound(:) = true;

    % Deal in order: P1..Pn, Dealer(up), P1..Pn, Dealer(hole)
    [myPlayers, dealerHand, playingDeck] = initialDealInOrder(myPlayers, nPlayers, playingDeck);
    disp("----- Initial Deal -----")

    % show player hands
    for p = 1:nPlayers
        showHand(string(myPlayers.name{p}) + " hand", myPlayers.hand{p});
    end

    % show only dealer up card
    disp("Dealer shows: " + dealerHand.cardName(1))

    % player logic, input hit or stand and evaluate if player busts
    for q = 1:nPlayers
        while true
            myPlayers.vals(q) = evaluateHand(myPlayers.hand{q}); % evaluate player hand
            disp(string(myPlayers.name{q}) + " hand value: " + myPlayers.vals(q)); % display player hand value

            if myPlayers.vals(q) > 21 % if player hand vallue exceeds 21
                disp("Bust! " + myPlayers.name(q) + " loses"); % display that player lost
                showHand(string(myPlayers.name{q}) + " final hand", myPlayers.hand{q}); % display the player's final hand
                myPlayers.inRound(q)= false; % set the player's inRound status to false (no longer in round)
                break % exit to for loop

            else % if player hand value is 21 or under
                playerDecision = input(string(myPlayers.name{q}) + ", Hit or Stand?", "s"); % player inputs hit/stand 
                
                if strcmpi(playerDecision, "stand") == true % if player input is stand (case insensitive)
                    disp(string(myPlayers.name{q}) + " stands.") % display decision
                    break % exit to for loop

                elseif strcmpi(playerDecision, "hit") == true % if player input is hit (case insensitive)
                    [newCard, playingDeck] = dealOneCard(playingDeck); % draw card
                    myPlayers.hand{q} = [myPlayers.hand{q}; newCard]; % append card to player's hand
                    disp(string(myPlayers.name{q}) + " draws: " + newCard.cardName); % display the card drawn
                    showHand(string(myPlayers.name{q}) + " hand", myPlayers.hand{q}); % show full hand

                else % if player inputs any other input
                    disp("Please type hit or stand."); % ask the question again

                end
            end
        end
    end

    if any(myPlayers.vals <= 21) % if any players are still left in the game, with hand values 21 and under
        [dealerHand, playingDeck] = dealerLogic(dealerHand, playingDeck); % use dealer logic to determine the dealer's actions
    end

    compareHands(nPlayers, myPlayers, dealerHand); % compare player hands with dealer hand to get results of round

    playAgain = lower(string(input("Play again? (y/n): ", "s"))); % ask if the players would like to play another round
end

%% My Local Functions

function myDeck = initDeck() % create deck

    % create array with card values 4 times
    myVals = [2:10, 10, 10, 10, 11]; 
    myVals = repmat(myVals, [1,4]);

    % create array with suit names
    mySuits=[repmat("Hearts", [1,13]),...
        repmat("Diamonds", [1,13]),...
        repmat("Clubs", [1,13]),...
        repmat("Spades", [1,13])];

    myDeck=table(); % create table named "myDeck"
    myDeck.vals=myVals';% transpose myVals and assign column in myDeck table
    myDeck.suits=mySuits';% transpose mySuits and assign column in myDeck table
    myDeck.cardName = string(myDeck.vals) + " of " + myDeck.suits; % third column in myDeck table has name of card

end


function shuffledDeck = shuffleDeck(myDeck) % shuffle deck
    shuffledDeck = myDeck(randperm(height(myDeck)), :);
end


function showHand(label, hand) % prints the cards in a hand with given label
    disp(label + ": " + strjoin(hand.cardName, ", "));
end


function [dealerHand, playingDeck] = dealerLogic(dealerHand, playingDeck) % reveal dealer card and prompt dealer decision
    disp("Dealer reveals: " + strjoin(dealerHand.cardName, ", ")) % display names of dealer cards
    [dealerHand, playingDeck] = dealerTurn(dealerHand, playingDeck); % results of dealer's decision
end


function [dealerHand, playingDeck] = dealerTurn(dealerHand, playingDeck) % decide whether dealer hits or stands
    dealerVal = evaluateHand(dealerHand); % value of dealer's hand

    while dealerVal < 17 
        [newCard, playingDeck] = dealOneCard(playingDeck); % deal card to dealer
        disp("Dealer draws: " + newCard.cardName); % show what dealer draws
        dealerHand = [dealerHand; newCard];  % append row to table
        showHand("Dealer Hand", dealerHand); % show new dealer hand
        dealerVal = evaluateHand(dealerHand); % value of dealer hand
    end

end


function compareHands (nPlayers, myPlayers, dealerHand) % compare player hands to dealer hand
   
    disp("--- Round Results ---") % display header

    dealerVal = evaluateHand(dealerHand); % find value of dealer hand
    disp("Dealer hand value = " + dealerVal); % display the dealer hand value
    
    for i=1:nPlayers % for each player
      
        playerVal = evaluateHand(myPlayers.hand{i}); % find value of player hand 
        disp(myPlayers.name{i} + " hand value = " + playerVal); % display player hand value

        if playerVal <= 21 && dealerVal > 21 % if player is still in and dealer busts
            disp("Dealer busts! " + myPlayers.name{i} + " wins!") % display the players that win

        elseif playerVal > 21 % if player hand is above 21
            disp(myPlayers.name{i} + " already busted. Dealer wins!") % reannounce that player busted

        elseif dealerVal == playerVal % if player hand and dealer hand are equal
            disp(myPlayers.name{i} + " draws with dealer!") % display a draw

        elseif dealerVal > playerVal % if dealer hand is greater than player hand
            disp (myPlayers.name{i} + " loses!") % display a loss

        else % if dealer hand is less than player hand
            disp (myPlayers.name{i} + " wins!") % display a win

        end
    end
end


function [card, playingDeck] = dealOneCard(playingDeck) % choose top card, clear from playingDeck
    card = playingDeck(1,:);     % 1-row table
    playingDeck(1,:) = [];       % remove from deck
end


function [myPlayers, dealerHand, playingDeck] = initialDealInOrder(myPlayers, nPlayers, playingDeck) % original deal
    
    % Initialize empty hands as empty tables with the same variables as playingDeck
    emptyHand = playingDeck([],:);

    % players and dealer initialized with empty hand
    for p = 1:nPlayers 
        myPlayers.hand{p} = emptyHand;
    end
    dealerHand = emptyHand;

    % first pass, each player gets 1 face-up card, then dealer gets 1 face-up card
    for p = 1:nPlayers
        [card, playingDeck] = dealOneCard(playingDeck);
        myPlayers.hand{p} = [myPlayers.hand{p}; card]; % append row of card chosen to the player's hand
    end
    [dealerUpCard, playingDeck] = dealOneCard(playingDeck);
    dealerHand = [dealerHand; dealerUpCard]; % append card chosen to dealer's hand

    % second pass, each player gets 1 face-up card, then dealer gets 1 face-down card
    for p = 1:nPlayers
        [card, playingDeck] = dealOneCard(playingDeck);
        myPlayers.hand{p} = [myPlayers.hand{p}; card]; % append card to player table
    end
    [dealerHoleCard, playingDeck] = dealOneCard(playingDeck);
    dealerHand = [dealerHand; dealerHoleCard]; % append card to dealer table

    % update numeric hand values (optional but convenient)
    for p = 1:nPlayers
        myPlayers.vals(p) = evaluateHand(myPlayers.hand{p});
    end
end


function handValue = evaluateHand(hand) % evaluate hand & change A if needed
    vals = hand.vals;
    handValue = sum(vals); % sums values of cards in hand

    while handValue > 21 && any(vals == 11) % when the hand is valued more than 21 and contains an Ace
        aceIndex = find(vals == 11, 1, "first"); % identifies the first Ace
        vals(aceIndex) = 1; % adjusts Ace value to 1
        handValue = sum(vals); % sums new values of cards
    end
end
