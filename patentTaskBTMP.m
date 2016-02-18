% Function to run graphical patent race task
% So far only setup so participant is the strong player
% And only 2 methods of weak player strategies implemented, 'RL', and
% learning from 'Fictive' earnings.
% Tobias Larsen, November 2015
% modified and amended Ben Timberlake, Feburary 2016

function [player1Earnings] = patentTaskBTMP(player2Strategy)

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
trialLength=nan(NUMROUNDS,1);           % Keeps track of length of each trial
% player2Strategy='Fictive';
player2Strategy='random'; %COMMENT AFTER DEBUGGING

%RESTORE AFTER DEBUGGING
% if (nargin<1)                           % If the function is called without update method
%     player2Strategy='random';
% end

%% Screen 1: Presentation

% win = 10 %COMMENT AFTER DEBUGGING
% screenRect = [0 0 640 480] %COMMENT AFTER DEBUGGING
[win, screenRect] = Screen('OpenWindow', 0, [255, 255 ,255], [0 0 640 480]); %black background

% Make a base Rect of 30 by 40 pixels
baseRect = [0 0 30 40];

% Get the size of the on-screen window
% screenXpixels=640 %COMMENT AFTER DEBUGGING
% screenYpixels=480 %COMMENT AFTER DEBUGGING
[screenXpixels, screenYpixels] = Screen('WindowSize', win);
% RESTORE AFTER DEBUGGING
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(screenRect);

%Rectangle positions
topRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36 screenXpixels * 0.45];
numtopRect = length(topRectXpos); % Screen X positions of top five rectangles
uppRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36];
numuppRect = length(uppRectXpos); % Screen X positions of upper four rectangles
botRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36 screenXpixels * 0.45 screenXpixels * 0.54 screenXpixels * 0.63 screenXpixels * 0.72 screenXpixels * 0.81 screenXpixels * 0.9];
numbotRect = length(botRectXpos); % Screen X positions of bottom ten rectangles
topRectYpos = screenYpixels * 0.2; % Screen Y positions of top five rectangles
uppRectYpos = screenYpixels * 0.4; % Screen Y positions of upper four rectangles
botRectYpos = screenYpixels * 0.8; % Screen Y positions of bottom ten rectangles

% Rectangle coordinates
topRects = nan(4, numtopRect); % Make coordinates for top row of rectangles
for i = 1:numtopRect
    topRects(:, i) = CenterRectOnPointd(baseRect, topRectXpos(i), topRectYpos);
end

uppRects = nan(4, numuppRect); % Make coordinates for upper row of rectangles
for i = 1:numuppRect
    uppRects(:, i) = CenterRectOnPointd(baseRect, uppRectXpos(i), uppRectYpos);
end

botRects = nan(4, numbotRect); % Make coordinates for bottom row of rectangles
for i = 1:numbotRect
    botRects(:, i) = CenterRectOnPointd(baseRect, botRectXpos(i), botRectYpos);
end

%set colors 
topColors = [0, 0, 0]; % black
uppColors = [0, 0, 0]; % black
botColors = [0, 0, 0]; % black

% Text positions
topTextYpos = screenYpixels * 0.1; % Screen Y positions of top text
uppTextYpos = screenYpixels * 0.3; % Screen Y positions of upper text
botTextYpos = screenYpixels * 0.7; % Screen Y positions of bottom text

% Select specific text font, style and size:
    Screen('TextFont', win, 'Courier New');
    Screen('TextSize', win, 24);
    Screen('TextStyle', win);
    Screen('TextColor', win, [0, 0, 0]);
    
% Instruction text strings
topInstructText = ['Select your investment (0 - ' num2str(PLAYER1MAXBID) ')'];
uppInstructText = ['Your opponent can invest up to ' num2str(PLAYER2MAXBID) '.'];
botInstructText = 'You can win 10, plus the amount you don''t invest';
% topWarningText = ['Your investment must be between 0 and ' num2str(PLAYER1MAXBID) '.'];

% Lose Result text strings
% topLoseText = topSelectText;
% uppLoseText = ['Your opponent invested ' num2str(player2Choice) '.'];
% botLoseText = ['You saved ' num2str(sum(player1Earnings)) '.']; %Why the sum? Should it just be for that round
% lowLoseText = ['Your opponent won ' num2str(sum(player2Earnings)) '.']; 

for i=1:NUMROUNDS
    
% Instruction screen
DrawFormattedText(win, topInstructText, topRectXpos(1), topTextYpos); % Draw betting instructions
Screen('FrameRect', win, topColors, topRects); % Draw the top rects to the screen
DrawFormattedText(win, uppInstructText, uppRectXpos(1), uppTextYpos); % Draw opponent explanation
Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
DrawFormattedText(win, botInstructText, botRectXpos(1), botTextYpos); % Draw reward explanation
Screen('FrameRect', win, botColors, botRects); % Draw the bottom rects to the screen 
Screen('Flip', win); % Flip to the screen
        trialStartTime(i) = GetSecs;

% myString=[];
% while true
% [keyPressed keyTime keyCode]=KbCheck;
% if keyPressed
% keyName=KbName(keyCode);
% if strcmp(keyName,'Return')
% break
% end
% keyName='';
% [keyTime keyCode]=KbWait
% keyName=KbName(keyCode)
% disp(keyName(1))
% 
% 
%     [secs, keyCode, deltaSecs] = KbWait([deviceNumber][, forWhat=0][, untilTime=inf])
%     [keyIsDown, secs, keyCode, deltaSecs] = KbCheck

currPlayerSelection=0;     % Set starting choice
keyName=''; % empty initial value

while(~strcmp(keyName,'space')) % continues until current keyName is space
%     keyName('space', 'LeftArrow', 'RightArrow')

[keyTime keyCode]=KbWait([],2);
keyName=KbName(keyCode);

        switch keyName
            case 'LeftArrow' 
                currPlayerSelection = currPlayerSelection - 1;
                if currPlayerSelection < 0
                    currPlayerSelection = 0;
                end
            case 'RightArrow'
                currPlayerSelection = currPlayerSelection + 1;
                if currPlayerSelection > PLAYER1MAXBID
                    currPlayerSelection = PLAYER1MAXBID;
                end
%             case 'space'
%             currPlayerSelection = player1Choice(i), exit switch
        end
        
        % update selection to last button press
SelectedRects = topRects(:,1:currPlayerSelection);
currUnselectRects = currPlayerSelection + 1;
unselectedRects = topRects(:,currUnselectRects:5);
            
% Redraw current selection
DrawFormattedText(win, topInstructText, topRectXpos(1), topTextYpos);
Screen('FillRect', win, topColors, SelectedRects); % Draw the top rects to the screen
Screen('FrameRect', win, topColors, unselectedRects);
DrawFormattedText(win, uppInstructText, uppRectXpos(1), uppTextYpos); % Draw opponent explanation
Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
DrawFormattedText(win, botInstructText, botRectXpos(1), botTextYpos); % Draw reward explanation
Screen('FrameRect', win, botColors, botRects); % Draw the bottom rects to the screen
Screen('Flip', win); % Flip to the screen

        
end

trialEndTime(i) = GetSecs;
player1Choice(i) = currPlayerSelection; 

% Selection text strings
topSelectText = ['You invested ' num2str(player1Choice(i)) '.'];
uppSelectText = 'Your opponent can invest up to 4';
botSelectText = botInstructText;

% DELETE this when change input functionality to arrow selection

    while(player1Choice(i) > PLAYER1MAXBID || player1Choice(i) < 0)             % Make sure the bid is within allowed range
        
        DrawFormattedText(win, topWarningText, topRectXpos(1), topTextYpos);        
        Screen('Flip', win); % Flip to the screen
        
        % Instruction screen again
        DrawFormattedText(win, topInstructText, topRectXpos(1), topTextYpos); % Draw betting instructions
        Screen('FrameRect', win, topColors, topRects); % Draw the top rects to the screen
        DrawFormattedText(win, uppInstructText, uppRectXpos(1), uppTextYpos); % Draw opponent explanation
        Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
        DrawFormattedText(win, botInstructText, botRectXpos(1), botTextYpos) % Draw reward explanation
        Screen('FrameRect', win, botColors, botRects); % Draw the bottom rects to the screen
        Screen('Flip', win); % Flip to the screen
        
        player1Choice(i)=input('Choice:');     % Get keyboard input from player1 (script pauses for input and if still invalid goes back into while loop. if valid, leaves while loop)
        
    end
    
    player1ChoiceInd = player1Choice(i)+1;      %because choosing 0 is an option, there's a discrepancy between choices and index of options...
    
    player2Choice(i)=find(rand < cumsum(exp(player2Options.*TAU)/sum(exp(player2Options.*TAU))),1);  % uses softmax to make a choice (TAU -> 0 = more random)
    
    player1Earnings(i) = PLAYER1MAXBID + (PRIZE-player1Choice(i))*(player1ChoiceInd > player2Choice(i)) - player1Choice(i)*(player1ChoiceInd<=player2Choice(i)); %calculates how much the strong player wins
    player2Earnings(i) = PLAYER2MAXBID + (PRIZE-player2Choice(i))*(player2Choice(i) > player1ChoiceInd) - player2Choice(i)*(player2Choice(i)<=player1ChoiceInd); %calculates how much the weak player wins
    player2Options = player2Update(player2Options, player2Strategy, player2Choice(i), player2Earnings(i), player1ChoiceInd, PRIZE, PLAYER2MAXBID);  %calls the function that determines how player2 will update its values
    
%% Screen 2: Player's selection
playerSelection = player1Choice(i);
selectedRects = topRects(:,1:playerSelection);
unSelected = playerSelection + 1;
unselectedRects = topRects(:,unSelected:5);

% Win Result text strings
topWinText = topSelectText;
uppWinText = ['Your opponent invested ' num2str(player2Choice(i)-1) '.'];
botWinText = ['You earned ' num2str(player1Earnings(i)) ' in this round.']; 
lowWinText = ['Your opponent earned ' num2str(player2Earnings(i)) ' in this round.']; 

% Draw choice explanation
DrawFormattedText(win, topSelectText, topRectXpos(1), topTextYpos);
Screen('FillRect', win, topColors, selectedRects); % Draw the top rects to the screen
Screen('FrameRect', win, topColors, unselectedRects);
DrawFormattedText(win, uppSelectText, uppRectXpos(1), uppTextYpos); % Draw opponent explanation
Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
DrawFormattedText(win, botSelectText, botRectXpos(1), botTextYpos); % Draw reward explanation
Screen('FrameRect', win, botColors, botRects); % Draw the bottom rects to the screen
Screen('Flip', win); % Flip to the screen

WaitSecs(1);

%% Screen 3: Result
weakSelection = num2str(player2Choice(i)-1);
weakselRects = uppRects(:,1:str2num(weakSelection));
weakunSelected = (str2num(weakSelection) + 1);
weakunselRects = uppRects(:,weakunSelected:4);

% display('test')

DrawFormattedText(win, topSelectText, topRectXpos(1), topTextYpos); % Draw strong outcome
Screen('FillRect', win, topColors, selectedRects); % Draw the top rects to the screen
Screen('FrameRect', win, topColors, unselectedRects);
DrawFormattedText(win, uppWinText, uppRectXpos(1), uppTextYpos); % Draw weak outcome
Screen('FillRect', win, uppColors, weakselRects); % Draw the upper rects to the screen
Screen('FrameRect', win, uppColors, weakunselRects);
%     Screen('TextStyle', win, 1); % change style to bold
DrawFormattedText(win, botWinText, botRectXpos(1), botTextYpos, botColors); % Draw reward explanation
Screen('FillRect', win, botColors, botRects); % Draw the bottom rects to the screen
Screen('Flip', win); % Flip to the screen

WaitSecs(4);

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

sca


%% End-of-block calculations and create log file
for i=1:NUMROUNDS
        trialLength(i) = trialEndTime(i)-trialStartTime(i);
end




end

