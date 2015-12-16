%%%%%%
% Function to run text based patent race task
% So far only setup so participant is the strong player
% And only 2 methods of weak player strategies implemented, 'RL', and
% learning from 'Fictive' earnings.
% Tobias Larsen, November 2015

% This is Martina's comment.

function [player1Earnings] = patentTask(player2Strategy)

PRIZE=10;                               % Winnings aside from bidding endowment, currently a fixed value
NUMROUNDS=20;                           % Number of rounds played against this opponent
PLAYER1MAXBID=5;                        % Endowment for player1
PLAYER2MAXBID=4;                        % Endowment for player2
TAU=2;                                  % Softmax temperature
player1Options=zeros(1,6);              % Not used yet, maybe never will...
player2Options=5*ones(1,5);             % Keeps track of the values for each betting amount
player1Earnings=nan(NUMROUNDS,1);       % Keeps track of winnings for player1
player2Earnings=nan(NUMROUNDS,1);       % Keeps track of winnings for player2
player1Choice=nan(NUMROUNDS,1);         % Keeps track of player1 choices
player2Choice=nan(NUMROUNDS,1);         % Keeps track of player2 choices
% player2Strategy='Fictive';
if (nargin<1)                           % If the function is called without update method
    player2Strategy='random';
end

for i=1:NUMROUNDS
    
    player1Choice(i)=input(['Enter bid (0-' num2str(PLAYER1MAXBID) '): ']);     % Get keyboard input from player1
    
    while(player1Choice(i) > PLAYER1MAXBID || player1Choice(i) < 0)             % Make sure the bid is within allowed range
        disp('Come on, man, between 0 and 5, it''s not rocket science')
        player1Choice(i)=input(['Enter bid (0-' num2str(PLAYER1MAXBID) '): ']);
    end
    player1ChoiceInd = player1Choice(i)+1;      %because choosing 0 is an option, there's a discrepancy between choices and index of options...
    
    player2Choice(i)=find(rand < cumsum(exp(player2Options.*TAU)/sum(exp(player2Options.*TAU))),1);  % uses softmax to make a choice (TAU -> 0 = more random)
    
    player1Earnings(i) = PLAYER1MAXBID + (PRIZE-player1Choice(i))*(player1ChoiceInd > player2Choice(i)) - player1Choice(i)*(player1ChoiceInd<=player2Choice(i)); %calculates how much the strong player wins
    player2Earnings(i) = PLAYER2MAXBID + (PRIZE-player2Choice(i))*(player2Choice(i) > player1ChoiceInd) - player2Choice(i)*(player2Choice(i)<=player1ChoiceInd); %calculates how much the weak player wins
    player2Options = player2Update(player2Options, player2Strategy, player2Choice(i), player2Earnings(i), player1ChoiceInd, PRIZE, PLAYER2MAXBID);  %calls the function that determines how player2 will update its values
    
    disp(['Player 2 chose: ' num2str(player2Choice(i)-1)]);
    disp(['You earned: ' num2str(player1Earnings(i)) ' in this round']);
end

disp(['Player 1 earned: ' num2str(sum(player1Earnings))]);
disp(['Player 2 earned: ' num2str(sum(player2Earnings))]);

end

function [player2Options] = player2Update(player2Options, player2Strategy, player2Choice, player2Earnings, player1Choice, PRIZE, PLAYER2MAXBID)
    alpha=0.5;  % learning rate for how quickly player2 adapts

    switch lower(player2Strategy)
        case 'rl'
            player2Options(player2Choice) = player2Options(player2Choice) + alpha*(player2Earnings-player2Options(player2Choice));      % Update value of chosen option based on earnings
        case 'fictive'
            player2FictEarn = PLAYER2MAXBID + (PRIZE-(0:PLAYER2MAXBID)).*((0:PLAYER2MAXBID) > player1Choice) - (0:PLAYER2MAXBID).*((0:PLAYER2MAXBID)<=player1Choice); %calculates the fictive earnings of each potential choice
            player2Options = player2Options + alpha*(player2FictEarn-player2Options);  %updates the value of each option based on the fictive earnings
        otherwise           % Default option is to not update the value of the options, making each choice random
            
    end

end
