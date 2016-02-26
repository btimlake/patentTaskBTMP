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
fixationDelay = 4 + (8-4).*rand(NUMROUNDS,1); % Creates array of random fixation cross presentation time of 4-8 seconds
feedbackDelay = 2 + (6-2).*rand(NUMROUNDS,1); % Creates array of random delay between choice and feedback of 2-6 seconds
KbName('UnifyKeyNames');
%RESTORE AFTER DEBUGGING
% if (nargin<1)                           % If the function is called without update method
%     player2Strategy='random';
% end
Screen('Preference', 'SkipSyncTests', 1); %COMMENT AFTER DEBUGGING

%% Screen -1: Participant number entry

%%% Enter participant number (taken from:
%%% http://www.academia.edu/2614964/Creating_experiments_using_Matlab_and_Psychtoolbox)
fail1='Please enter a participant number.'; %error message
prompt = {'Enter participant number:'};
dlg_title ='New Participant';
num_lines = 1;
def = {'0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);%presents box to enterdata into
switch isempty(answer)
    case 1 %deals with both cancel and X presses 
        error(fail1)
    case 0
        particNum=(answer{1});
end

%% Screen 0: Instructions
% win = 10 %COMMENT AFTER DEBUGGING

% screenRect = [0 0 640 480] %COMMENT AFTER DEBUGGING
[win, screenRect] = Screen('OpenWindow', 0, [255, 255 ,255], [0 0 640 480]); %white background
% [win, screenRect] = Screen('OpenWindow', 0, [255, 255 ,255]); %white background

%set colors 
topColors = [0, 0, 0]; % black
uppColors = [0, 0, 0]; % black
botColors = [0, 0, 0]; % black

% Get the size of the on-screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', win);
% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(screenRect);


%Rectangle positions
topRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36 screenXpixels * 0.45];
numtopRect = length(topRectXpos); % Screen X positions of top five rectangles
uppRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36];
numuppRect = length(uppRectXpos); % Screen X positions of upper four rectangles
lowRectXpos = [screenXpixels * 0.09 screenXpixels * 0.18 screenXpixels * 0.27 screenXpixels * 0.36 screenXpixels * 0.45 screenXpixels * 0.54 screenXpixels * 0.63 screenXpixels * 0.72 screenXpixels * 0.81 screenXpixels * 0.9];
numlowRect = length(lowRectXpos); % Screen X positions of lower ten rectangles
botRectXpos = [screenXpixels * 0.54 screenXpixels * 0.63 screenXpixels * 0.72 screenXpixels * 0.81 screenXpixels * 0.9];
numbotRect = length(botRectXpos); % Screen X positions of bottom five rectangles
topRectYpos = screenYpixels * 7/40; % Screen Y positions of top five rectangles (4/40)
uppRectYpos = screenYpixels * 16/40; % Screen Y positions of upper four rectangles (13/40)
sepLineYpos = screenYpixels * 19/40; % Screen Y position of separator line
lowRectYpos = screenYpixels * 27/40; % Screen Y positions of lower ten rectangles (24/40)
botRectYpos = screenYpixels * 34/40; % Screen Y positions of bottom five rectangles (31/40)

% Text positions
topTextYpos = screenYpixels * 2/40; % Screen Y positions of top text (3/40)
uppTextYpos = screenYpixels * 11/40; % Screen Y positions of upper text (12/40)
lowTextYpos = screenYpixels * 22/40; % Screen Y positions of lower text (23/40)
botTextYpos = screenYpixels * 30/40; % Screen Y positions of bottom text 
textXpos = (screenXpixels * 0.09 - screenXpixels * 2/56);
lineEndXpos = (screenXpixels * 0.91 + screenXpixels * 2/56);
% Instruct text positions
instruct1TextYpos = screenYpixels * 2/40; 
instruct2TextYpos = screenYpixels * 6/40; 
instruct3TextYpos = screenYpixels * 10/40; 
instruct4TextYpos = screenYpixels * 14/40; 
instruct5TextYpos = screenYpixels * 18/40; 
instruct6TextYpos = screenYpixels * 22/40; 
instructbotTextYpos = screenYpixels * 30/40; 


% Select specific text font, style and size:
fontSize = screenYpixels * 2/40;
    Screen('TextFont', win, 'Courier New');
    Screen('TextSize', win, fontSize);
    Screen('TextStyle', win);
    Screen('TextColor', win, [0, 0, 0]);
    
% participantNumber(i)=input('Enter your:');     % Get keyboard input from player1 (script pauses for input and if still invalid goes back into while loop. if valid, leaves while loop)

instructText11 = ['You are competing against an opponent to win a prize in each trial.'];
instructText12 = ['You can invest 0-' num2str(PLAYER1MAXBID) ' cards. Your opponent can invest 0-' num2str(PLAYER2MAXBID) '.'];
instructText13 = ['The player who invests more wins 10.'];
instructText14 = ['If both invest the same amount, neither player wins.'];
instructText15 = ['Whatever you don''t invest, you keep.'];
instructText16 = ['(e.g. if you invest 3, you keep 2, whether you win or lose.)'];
instructText17 = ['Hit the SPACE bar to continue.'];
instructText21 = ['Use the arrow keys to select how many to invest.'];
instructText22 = ['Hit the SPACE bar to confirm your choice.'];

keyName=''; % empty initial value

while(~strcmp(keyName,'space')) % continues until current keyName is space
%     keyName('space', 'LeftArrow', 'RightArrow')



DrawFormattedText(win, instructText11, 'center', instruct1TextYpos); % Draw betting instructions
DrawFormattedText(win, instructText12, 'center', instruct2TextYpos); % Draw betting instructions
DrawFormattedText(win, instructText14, 'center', instruct3TextYpos); % Draw betting instructions
DrawFormattedText(win, instructText15, 'center', instruct4TextYpos); % Draw betting instructions
DrawFormattedText(win, instructText16, 'center', instruct5TextYpos); % Draw betting instructions
DrawFormattedText(win, instructText17, 'center', instructbotTextYpos); % Draw betting instructions
Screen('Flip', win); % Flip to the screen
[keyTime, keyCode]=KbWait([],2);
keyName=KbName(keyCode);

end


while(~strcmp(keyName,'space')) % continues until current keyName is space
%     keyName('space', 'LeftArrow', 'RightArrow')

[keyTime, keyCode]=KbWait([],2);
keyName=KbName(keyCode);

DrawFormattedText(win, instructText21, 'center', instruct1TextYpos); % Draw betting instructions
DrawFormattedText(win, instructText22, 'center', instruct2TextYpos); % Draw betting instructions
DrawFormattedText(win, instructText17, 'center', instructbotTextYpos); % Draw betting instructions
Screen('Flip', win); % Flip to the screen

end


%% Screen 1: Presentation

% win = 10 %COMMENT AFTER DEBUGGING
% screenRect = [0 0 640 480] %COMMENT AFTER DEBUGGING
% [win, screenRect] = Screen('OpenWindow', 0, [255, 255 ,255], [0 0 640 480]); %white background

% Make a base Rect 4/56th of the screen width and 5/33rds of the height
rectWidth = screenXpixels * 4 / 56;
rectHeight = screenYpixels * 5 / 40;
baseRect = [0 0 rectWidth rectHeight];


% Rectangle coordinates
topRects = nan(4, numtopRect); % Make coordinates for top row of rectangles
for i = 1:numtopRect
    topRects(:, i) = CenterRectOnPointd(baseRect, topRectXpos(i), topRectYpos);
end

uppRects = nan(4, numuppRect); % Make coordinates for upper row of rectangles
for i = 1:numuppRect
    uppRects(:, i) = CenterRectOnPointd(baseRect, uppRectXpos(i), uppRectYpos);
end


lowRects = nan(4, numlowRect); % Make coordinates for bottom row of rectangles
for i = 1:numlowRect
    lowRects(:, i) = CenterRectOnPointd(baseRect, lowRectXpos(i), lowRectYpos);
end

botRects = nan(4, numbotRect); % Make coordinates for bottom row of rectangles
for i = 1:numbotRect
    botRects(:, i) = CenterRectOnPointd(baseRect, botRectXpos(i), botRectYpos);
end

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

% Trials begin here
for i=1:NUMROUNDS

%% Screen 1a: Fixation cross
fixCrossDimPix = screenXpixels * 4 / 56; % Arm size

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = screenXpixels * 40 / 56;

% Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
% Screen('DrawLines', win, allCoords, lineWidthPix, uppColors, [xCenter yCenter], 2);

% Flip to the screen
Screen('Flip', win);

% Wait for 4-8 seconds
WaitSecs(fixationDelay(i));


%% Screen 1b: Presentation screen
DrawFormattedText(win, topInstructText, textXpos, topTextYpos); % Draw betting instructions
Screen('FrameRect', win, topColors, topRects); % Draw the top rects to the screen
DrawFormattedText(win, uppInstructText, textXpos, uppTextYpos); % Draw opponent explanation
Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
Screen('DrawLine', win, textXpos, sepLineYpos, lineEndXpos, sepLineYpos, lineWidthPix); % Make this a line separating the sections
DrawFormattedText(win, botInstructText, textXpos, lowTextYpos); % Draw reward explanation
Screen('FrameRect', win, botColors, lowRects); % Draw the lower rects to the screen 
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

[keyTime, keyCode]=KbWait([],2);
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

DrawFormattedText(win, topInstructText, textXpos, topTextYpos);
% Screen('FillRect', win, topColors, SelectedRects); % Draw the top rects to the screen
Screen('FrameRect', win, topColors, topRects);
DrawFormattedText(win, uppInstructText, textXpos, uppTextYpos); % Draw opponent explanation
Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
DrawFormattedText(win, botInstructText, textXpos, lowTextYpos); % Draw reward explanation
Screen('FrameRect', win, botColors, lowRects); % Draw the lower rects to the screen 
Screen('FrameRect', win, botColors, botRects); % Draw the bottom rects to the screen 


if currPlayerSelection ~= 0
    selectedRects = topRects(:,1:currPlayerSelection);    
    Screen('FillRect', win, topColors, selectedRects); % Draw the top rects to the screen
else
    selectedRects=0;
end

Screen('Flip', win); % Flip to the screen
            
end

trialEndTime(i) = GetSecs;
player1Choice(i) = currPlayerSelection; 

% Selection text strings
topSelectText = ['You invested ' num2str(player1Choice(i)) '.'];
uppSelectText = 'Your opponent can invest up to 4';
botSelectText = botInstructText;

% DELETE this when change input functionality to arrow selection

%     while(player1Choice(i) > PLAYER1MAXBID || player1Choice(i) < 0)             % Make sure the bid is within allowed range
%         
%         DrawFormattedText(win, topWarningText, textXpos, topTextYpos);        
%         Screen('Flip', win); % Flip to the screen
%         
%         % Instruction screen again
%         DrawFormattedText(win, topInstructText, textXpos, topTextYpos); % Draw betting instructions
%         Screen('FrameRect', win, topColors, topRects); % Draw the top rects to the screen
%         DrawFormattedText(win, uppInstructText, textXpos, uppTextYpos); % Draw opponent explanation
%         Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
%         DrawFormattedText(win, botInstructText, textXpos, lowTextYpos); % Draw reward explanation
%         Screen('FrameRect', win, botColors, lowRects); % Draw the lower rects to the screen
%         Screen('FrameRect', win, botColors, botRects); % Draw the bottom rects to the screen
%         Screen('Flip', win); % Flip to the screen
%         
%         player1Choice(i)=input('Choice:');     % Get keyboard input from player1 (script pauses for input and if still invalid goes back into while loop. if valid, leaves while loop)
%         
%     end
    
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
DrawFormattedText(win, topSelectText, textXpos, topTextYpos);
if currPlayerSelection ~= 0
    Screen('FillRect', win, topColors, selectedRects); % Draw the top rects to the screen
end
Screen('FrameRect', win, topColors, topRects);
DrawFormattedText(win, uppSelectText, textXpos, uppTextYpos); % Draw opponent explanation
Screen('FrameRect', win, uppColors, uppRects); % Draw the upper rects to the screen
DrawFormattedText(win, botInstructText, textXpos, lowTextYpos); % Draw reward explanation
Screen('FrameRect', win, botColors, lowRects); % Draw the lower rects to the screen 
Screen('FrameRect', win, botColors, botRects); % Draw the bottom rects to the screen 
% Screen('FrameRect', win, botColors, unselectWinRects); % Draw the lower lost rects to the screen
% Screen('FillRect', win, botColors, selectedWinRects); % Draw the lower retained rects to the screen
% Screen('FrameillRect', win, topColors, selectedRects); % Draw the lower lost rects to the screen
% Screen('FillRect', win, topColors, unselectedRects);

% show filled rects if win / empty rects if lost
% if player1Choice(i) > player2Choice(i)
%     Screen('FillRect', win, botColors, rewardRects); % Draw the lower retained rects to the screen
%     Screen('FillRect', win, botColors, botRects); % Draw the bottom won rects to the screen
% else
%     Screen('FrameRect', win, botColors, rewardRects); % Draw the lower lost rects to the screen
%     Screen('FrameRect', win, botColors, botRects); % Draw the bottom lost rects to the screen
% end
Screen('Flip', win); % Flip to the screen

WaitSecs(feedbackDelay(i));

%% Screen 3: Result
weakSelection = player2Choice(i)-1;
if weakSelection ~= 0
    weakselRects = uppRects(:,1:weakSelection);
else
    weakselRects=0;
end
% weakunSelected = (str2num(weakSelection) + 1);
% weakunselRects = uppRects(:,weakunSelected:4);
if player1Choice(i) < PLAYER1MAXBID
    selectedWinRects = lowRects(:,player1Choice(i)+1:PLAYER1MAXBID);
else
    selectedWinRects=0;
end
% lostRects = playerSelection - 1;
% unselectWinRects = lowRects(:,1:currPlayerSelection);
% rewardRects = lowRects(:,6:10);

% display('test')
Screen('FrameRect', win, topColors, topRects);
Screen('FrameRect', win, uppColors, uppRects);
Screen('FrameRect', win, botColors, lowRects); 
Screen('FrameRect', win, botColors, botRects); 

%     Screen('TextStyle', win, 1); % change style to bold
DrawFormattedText(win, topSelectText, textXpos, topTextYpos); % Draw strong outcome
DrawFormattedText(win, uppWinText, textXpos, uppTextYpos); % Draw weak outcome
DrawFormattedText(win, botInstructText, textXpos, lowTextYpos); % Draw reward explanation

if selectedRects
    Screen('FillRect', win, topColors, selectedRects); % Draw the top rects to the screen
end
if weakselRects
    Screen('FillRect', win, uppColors, weakselRects); % Draw the upper rects to the screen
end
if selectedWinRects
    Screen('FillRect', win, botColors, selectedWinRects); % Draw the lower retained rects to the screen
end

% show filled rects if win / empty rects if lost
if player1Choice(i) > player2Choice(i)
%     Screen('FillRect', win, botColors, rewardRects); % Draw the lower retained rects to the screen
    Screen('FillRect', win, botColors, botRects); % Draw the bottom won rects to the screen
% else
%     Screen('FrameRect', win, botColors, rewardRects); % Draw the lower lost rects to the screen
%     Screen('FrameRect', win, botColors, botRects); % Draw the bottom lost rects to the screen
end
% Screen('FrameRect', win, botColors, lowRects); % Draw the lower rects to the screen
% Screen('FillRect', win, botColors, botRects); % Draw the bottom rects to the screen
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


save(['patent race ' particNum])

end




