% Function to run text based patent race task
% So far only setup so participant is the strong player
% And only 2 methods of weak player strategies implemented, 'RL', and
% learning from 'Fictive' earnings.
% Tobias Larsen, November 2015

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

% Patent race task
% 
% Work with Martina to get screen progression
% 	- martina re Tobias
% 		- three screens: presentation, selection, outcome: just button press for now
% 		
% 3 screens
% Steps
% 1 Rectangles display
% w/o underlying behavior (i.e. any button to get to next scren)
% 
% 2 integrate mathematics
% 
% 3 write to log file
% 
% ====
% Tuesday: Graphical portion


%% Screen 1: Presentation
% based on some material from Scarfe PTB tutorial
clear

% win = 10 %COMMENT AFTER DEBUGGING
% screenRect = [0 0 640 480] %COMMENT AFTER DEBUGGING
[win, screenRect] = Screen('OpenWindow', 0, [127 127 127], [0 0 640 480]);

% Make a base Rect of 30 by 40 pixels
baseRect = [0 0 30 40];

% Get the size of the on-screen window
% screenXpixels=640 %COMMENT AFTER DEBUGGING
% screenYpixels=480 %COMMENT AFTER DEBUGGING
[screenXpixels, screenYpixels] = Screen('WindowSize', win);
% RESTORE AFTER DEBUGGING
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(screenRect);

% Screen X positions of top five rectangles
topRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36 screenXpixels * 0.45];
numtopRect = length(topRectXpos);
% Screen X positions of upper four rectangles
uppRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36];
numuppRect = length(uppRectXpos);
% Screen X positions of bottom ten rectangles
botRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36 screenXpixels * 0.45 screenXpixels * 0.54 screenXpixels * 0.63 screenXpixels * 0.72 screenXpixels * 0.81 screenXpixels * 0.9];
numbotRect = length(botRectXpos);

% Screen Y positions of top five rectangles
topRectYpos = screenYpixels * 0.2;
% Screen Y positions of upper four rectangles
uppRectYpos = screenYpixels * 0.4;
% Screen Y positions of bottom ten rectangles
botRectYpos = screenYpixels * 0.8;

% Make coordinates for top row of rectangles
topRects = nan(4, 3);
for i = 1:numtopRect
    topRects(:, i) = CenterRectOnPointd(baseRect, topRectXpos(i), topRectYpos);
end

% Make coordinates for upper row of rectangles
uppRects = nan(4, 3);
for i = 1:numuppRect
    uppRects(:, i) = CenterRectOnPointd(baseRect, uppRectXpos(i), uppRectYpos);
end

% Make coordinates for bottom row of rectangles
botRects = nan(4, 3);
for i = 1:numbotRect
    botRects(:, i) = CenterRectOnPointd(baseRect, botRectXpos(i), botRectYpos);
end

%set colors to blue, yellow, green
topColors = [0, 0, 255];
uppColors = [255, 200, 0];
botColors = [40, 155, 40];

% Screen Y positions of top text
topTextYpos = screenYpixels * 0.1;
% Screen Y positions of upper text
uppTextYpos = screenYpixels * 0.3;
% Screen Y positions of bottom text
botTextYpos = screenYpixels * 0.7;

% Select specific text font, style and size:
    Screen('TextFont', win, 'Courier New');
    Screen('TextSize', win, 24);
    Screen('TextStyle', win);

% Instruction text strings
topInstructText = 'Select your investment (up to 5)';
uppInstructText = 'Your opponent can invest up to 4';
botInstructText = 'You can win 10';

% Draw betting instructions
DrawFormattedText(win, topInstructText, topRectXpos(1), topTextYpos)
% Draw the top rects to the screen
Screen('FrameRect', win, topColors, topRects);

% Draw opponent explanation
DrawFormattedText(win, uppInstructText, uppRectXpos(1), uppTextYpos)
% Draw the upper rects to the screen
Screen('FrameRect', win, uppColors, uppRects);

% Draw reward explanation
DrawFormattedText(win, botInstructText, botRectXpos(1), botTextYpos)
% Draw the bottom rects to the screen
Screen('FrameRect', win, botColors, botRects);

% Flip to the screen
Screen('Flip', win);

noClickYet=true;

while noClickYet % as long as this is true
    [mouseX, mouseY, buttons] = GetMouse(win); % record mouse click
    %change the value of noClickYet (and break the loop) only if the click
    %is inside my oneRect
    if buttons(1)
        noClickYet=false;
        %         for k = 1:totalNumberRect %for each rect, this loop check if the button was within the coordinates.
        %             thisRect= myTrials(k).rect;
        %             if mouseX>thisRect(1) & ...
        %                     mouseX<thisRect(3) & ...
        %                     mouseY>thisRect(2) & ...
        %                     mouseY<thisRect(4)
        %                 myTrials(k)=[];
        %                 break
        %             end
        %         end
    end
end

%% Screen 2: Player's selection

buttons(1) = 0;

playerSelection = 4;
selectedRects = topRects(:,1:playerSelection);
unSelected = playerSelection + 1;
unselectedRects = topRects(:,unSelected:5);

% Instruction text strings
topSelectText = ['You invested ' num2str(playerSelection) '.']
uppSelectText = 'Your opponent can invest up to 4';
botSelectText = 'You can win 10';

% Draw betting instructions
DrawFormattedText(win, topSelectText, topRectXpos(1), topTextYpos)
% Draw the top rects to the screen
Screen('FillRect', win, topColors, selectedRects);
Screen('FrameRect', win, topColors, unselectedRects);

% Draw opponent explanation
DrawFormattedText(win, uppSelectText, uppRectXpos(1), uppTextYpos)
% Draw the upper rects to the screen
Screen('FrameRect', win, uppColors, uppRects);

% Draw reward explanation
DrawFormattedText(win, botSelectText, botRectXpos(1), botTextYpos)
% Draw the bottom rects to the screen
Screen('FrameRect', win, botColors, botRects);

% Flip to the screen
Screen('Flip', win);

noClickYet=true;

while noClickYet % as long as this is true
    [mouseX, mouseY, buttons] = GetMouse(win); % record mouse click
    %change the value of noClickYet (and break the loop) only if the click
    %is inside my oneRect
    if buttons(1)
        noClickYet=false;
        %         for k = 1:totalNumberRect %for each rect, this loop check if the button was within the coordinates.
        %             thisRect= myTrials(k).rect;
        %             if mouseX>thisRect(1) & ...
        %                     mouseX<thisRect(3) & ...
        %                     mouseY>thisRect(2) & ...
        %                     mouseY<thisRect(4)
        %                 myTrials(k)=[];
        %                 break
        %             end
        %         end
    end
end


%% Screen 3: Result

buttons(1) = 0;

weakSelection = 3;
weakselRects = uppRects(:,1:weakSelection);
weakunSelected = weakSelection + 1;
weakunselRects = uppRects(:,weakunSelected:4);

% Instruction text strings
% topResultText = ['You invested ' num2str(playerSelection) '.']
uppResultText = ['Your opponent invested ' num2str(weakSelection) '.'];
botResultText = 'You won 10.';

% Draw strong outcome
DrawFormattedText(win, topSelectText, topRectXpos(1), topTextYpos)
% Draw the top rects to the screen
Screen('FillRect', win, topColors, selectedRects);
Screen('FrameRect', win, topColors, unselectedRects);

% Draw weak outcome
DrawFormattedText(win, uppResultText, uppRectXpos(1), uppTextYpos)
% Draw the upper rects to the screen
Screen('FillRect', win, uppColors, weakselRects);
Screen('FrameRect', win, uppColors, weakunselRects);

% Draw reward explanation
    Screen('TextStyle', win, 1); % change style to bold
DrawFormattedText(win, botResultText, botRectXpos(1), botTextYpos, botColors)
% Draw the bottom rects to the screen
Screen('FillRect', win, botColors, botRects);

% Flip to the screen
Screen('Flip', win);

noClickYet=true;

while noClickYet % as long as this is true
    [mouseX, mouseY, buttons] = GetMouse(win); % record mouse click
    %change the value of noClickYet (and break the loop) only if the click
    %is inside my oneRect
    if buttons(1) == 0
        noClickYet=false;
        %         for k = 1:totalNumberRect %for each rect, this loop check if the button was within the coordinates.
        %             thisRect= myTrials(k).rect;
        %             if mouseX>thisRect(1) & ...
        %                     mouseX<thisRect(3) & ...
        %                     mouseY>thisRect(2) & ...
        %                     mouseY<thisRect(4)
        %                 myTrials(k)=[];
        %                 break
        %             end
        %         end
    end
end

sca

        

