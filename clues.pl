% Clues Project

% We implemented the basic requirement for clues.

%After loading the program, type "clues." to begin the game. 
%You will then be asked to input the configuration of the game. 
%Once the game beings, you will be asked what you want to do each time it is your turn. 
%The program is unable to tell you which specfic suggestions to make, 
%but anytime you wish to make a suggestion you can peak at the feasible options remaining by typing "dat.". 
%The program works by building a dynamic database of the cards involved in the game, 
%and then retracts from that database based on the suggestion made during gameplay.  

% If you choose to make an accusation, the program would print all the cards that are not in your hand
% and the cards that you do not know if they are in other players hands or in the secret envolope
% so that you can pick three cards from the list and make the accusation.


:- dynamic suspect/1.
:- dynamic weapon/1.
:- dynamic room/1.
:- dynamic mycard/1.
 
clues :-
    initialSetUp,
% start game from the first player
    startgame(1)
.
 
% initial setup of the game
%Asking the player for suspects, weapons, rooms, and his/her own cards
% how many plays / which turn is the player
initialSetUp :-
    write("Start the game Clues."),nl,nl,
    inputSuspects,
    inputWeapons,
    inputRooms,
    inputOwnCards,
    setup,
    nl
.
 
 

 
% Player Xs turn for the game    
% if it is my turn, then I make a suggestion
% check who showed me a card
 
startgame(PlayerX) :-
	%write("Player "), write(PlayerX), write("\'s turn"),nl,
    myTurn(X),
 
% check if its my turn
% if there are only 3 possible cards left, tell the player to make an accusation. Otherwise, ask  
%then what they have decided to do.      
(X = PlayerX -> write("It is your turn now!"), nl,
    write("Would you want to make a suggestion 'seg', an accusation 'acc', look at the database 'dat', or to skip 'skip'?"),
        read(Choice),
        (Choice = 'seg' -> suggestion;
        Choice = 'acc' -> accusation;
	Choice = 'dat' -> showDatabase),nl
    ),

      
    % if not the players turn, higher level      
 
    %nextturn
    NextPlayer is PlayerX + 1,
    totalPlayers(TP),
    (NextPlayer > TP -> NextPlayer = 1);
     startgame(NextPlayer)
.
 
% check who showed me a card during my suggestion and delete that card    
suggestion :-
    write("What's your suggestion? Enter suspect: "),nl,
    read(Sus),
    write("Enter weapon: "),nl,
    read(Wep),
    write("Enter room: "),nl,
    read(Roo),

    write("Is there anyone showed you a card? Enter that card, if none just type 'none'."),         nl,
    read(Card),
    (suspect(Card) -> retract(suspect(Card));
    weapon(Card) -> retract(weapon(Card));
    room(Card) -> retract(room(Card));
    Card = 'none' -> (not(checkMyhand(Sus, Wep, Roo)) -> write("Since no one showed you a card, and none of the suggested cards are in your hand, make an accusation with the same cards now!"), halt)), 
    checkNumCards
.
 
checkMyhand(Sus, Wep, Roo):-
	mycard(Sus);
	mycard(Wep);
	mycard(Roo)
. 

showDatabase:- 
	write("Cards that may still be in the secret file:"),nl,
	write("suspects:"),nl,
	listing(suspect),nl,
	write("rooms:"),nl,
	listing(room),nl,
	write("weapons:"),nl,
	listing(weapon),nl
.

accusation :- showDatabase, write("Go ahead and make an accusation. Bye."), halt.
 
 
checkNumCards :-
    aggregate_all(count, suspect(_), SuspCount),
    aggregate_all(count, room(_), RoomCount),
    aggregate_all(count, weapon(_), WeaponCount),
    (SuspCount = 1 ->  
        (RoomCount = 1 ->
            (WeaponCount = 1 ->  
                write("You can now make an accusation."),nl,
                suspect(S),
                room(R),
                weapon(W),
                write("There are only 3 cards left: "),
                write(S), write(", "), write(R), write(", and "), write(W), write("."), nl, write("Good Game!"),halt
            )
        )
    ); true
%    myTurn(MT),
%    NT is MT + 1,
%    totalPlayers(TP),
%    (NP > TP -> NP = 1);  
%    startgame(NT)
.
 
inputSuspects :-
    write("Enter a suspect or \'finished\' when done: "),nl,
    read(Suspect),    
    (Suspect \= finished ->    
        (suspect(Suspect) -> write("You have already entered this suspect.");
        assert(suspect(Suspect))
    ),
        inputSuspects
    );
    true
.
 
inputWeapons :-
    write("Enter a weapon or \'finished\' when done: "),
    read(Weapon),    
    (Weapon \= finished ->
        (weapon(Weapon) -> write("You have already entered this weapon.");
        assert(weapon(Weapon))
    ),
        inputWeapons
    );
    true
.
 
inputRooms :-
    write("Enter a room or \'finished\' when done: "),
    read(Room),    
    (Room \= finished ->
        (room(Room) -> write("You have already entered this room.");
        assert(room(Room))
    ),
        inputRooms
    );
    true
.
 

inputOwnCards :-
    write("Enter one of your card or \'finished\' when done: "),
    read(Card),    
    (Card \= finished ->
        (mycard(Card) -> write("You have already entered this card.");
        assert(mycard(Card)),
	(suspect(Card) -> retract(suspect(Card));
	 weapon(Card) -> retract(weapon(Card));
	 room(Card) -> retract(room(Card))
	 )
    ),
        inputOwnCards
    );
    true
.
 
% how many plays / which turn is the player
setup :-
    write("How many players in total?"),
    read(TotalPlayers),
    write("When is your turn? (Enter a number)"),
    read(MyTurn),
    (MyTurn > TotalPlayers -> write("Cannot have your turn number greater than total players. Try again."),nl, setup;
    assert(totalPlayers(TotalPlayers)),
    assert(myTurn(MyTurn))
)
.






