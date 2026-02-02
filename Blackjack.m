clear; clc;
%% Ready, Set, Start! 

% Asking for the number of players
nPlayers = input("How many players? ");  % numeric input

% initialize deck 
myDeck= initDeck();

%% initialize players
myPlayers = struct(); % create array for players
myPlayers.name = cell(nPlayers, 1); %name the first column of myPlayers "name"

for i = 1:nPlayers 
    myPlayers.name{i} = input("Player "+ i + " name: ", "s");
end 

myPlayers.money = repmat(1000, [nPlayers, 1]);
myPlayers.hand    = cell(nPlayers, 1);            % each will hold a table of cards
myPlayers.vals = zeros(nPlayers, 1);           % numeric hand value per player
myPlayers.inRound = true(nPlayers, 1);            % still playing this round (not busted)

%% Main loop 
playAgain = "y";
while playAgain == "y"

    playingDeck = shuffleDeck(myDeck);
    disp("----- NEW ROUND -----")
    disp("Players: " + nPlayers)
    disp("Deck size at start: " + height(playingDeck))


    % Reset round state if needed
    myPlayers.inRound(:) = true;

    % Deal in order: P1..Pn, Dealer(up), P1..Pn, Dealer(hole)
    [myPlayers, dealerHand, playingDeck] = initialDealInOrder(myPlayers, nPlayers, playingDeck);
    disp("----- Initial Deal -----")
    disp("Dealer shows: " + dealerHand.cardName(1))

    for p = 1:nPlayers
        showHand(string(myPlayers.name{p}) + " hand", myPlayers.hand{p});
    end

    % Show only dealer up card
    disp("Dealer shows: " + dealerHand.cardName(1))
    
    for q = 1:nPlayers
        while true
            myPlayers.vals(q) = evaluateHand(myPlayers.hand{q});
            disp(string(myPlayers.name{q}) + " hand value: " + myPlayers.vals(q));
            if myPlayers.vals(q) > 21
                disp("Bust! " + myPlayers.vals(q) + " loses");
                showHand(string(myPlayers.name{q}) + " final hand", myPlayers.hand{q});

                break
            else
                playerDecision = input(string(myPlayers.name{q}) + ", Hit or Stand?", "s");
                    if strcmpi(playerDecision, "stand") == true
                        disp(string(myPlayers.name{q}) + " stands.")
                        break
                    elseif strcmpi(playerDecision, "hit") == true
                        [newCard, playingDeck] = dealOneCard(playingDeck);
                        myPlayers.hand{q} = [myPlayers.hand{q}; newCard];
                        disp(string(myPlayers.name{q}) + " draws: " + newCard.cardName)
                        showHand(string(myPlayers.name{q}) + " hand", myPlayers.hand{q});
                    else
                        disp("Please type hit or stand.");
                    end

            end
        end
    end

    if any(myPlayers.vals <= 21)
    [dealerHand, playingDeck] = dealerLogic(dealerHand, playingDeck);
    end
%need to add dealerLogic in here somewhere
%also add money aspect
%showHand does not show up either
    playAgain = lower(string(input("Play again? (y/n): ", "s")));
end

%% my local functions

function myDeck = initDeck() %create deck

%create array with card values 4 times
myVals = [2:10, 10, 10, 10, 11]; 
myVals = repmat(myVals, [1,4]);

%create array with suit names
mySuits=[repmat("Hearts", [1,13]),...
    repmat("Diamonds", [1,13]),...
    repmat("Clubs", [1,13]),...
    repmat("Spades", [1,13])];

myDeck=table(); %create table named "myDeck"
myDeck.vals=myVals';%transpose myVals and assign column in myDeck table
myDeck.suits=mySuits';%transpose mySuits and assign column in myDeck table
myDeck.cardName = string(myDeck.vals) + " of " + myDeck.suits; %third column in myDeck table has name of card
end


function shuffledDeck = shuffleDeck(myDeck) %shuffle deck
    shuffledDeck = myDeck(randperm(height(myDeck)), :);
end


function showHand(label, hand)
    % This function prints the cards in a hand and the evaluated value.
    disp(label + ": " + strjoin(hand.cardName, ", "))
    disp("Value = " + evaluateHand(hand))
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


function [dealerHand, playingDeck] = dealerLogic(dealerHand, playingDeck) % reveal dealer card and prompt dealer decision
    disp("Dealer reveals: " + strjoin(dealerHand.cardName, ", "))
    [dealerHand, playingDeck] = dealerTurn(dealerHand, playingDeck);
end


function [dealerHand, playingDeck] = dealerTurn(dealerHand, playingDeck) % decide whether dealer hits or stands
    dealerVal = evaluateHand(dealerHand); % value of dealer's hand

    while dealerVal < 17 
        [newCard, playingDeck] = dealOneCard(playingDeck); % deal card to dealer
        dealerHand = [dealerHand; newCard];  % append row to table
        dealerVal = evaluateHand(dealerHand); % value of dealer hand
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