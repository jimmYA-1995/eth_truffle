pragma solidity >=0.5.1;
contract TicTacToe {
    uint constant public gameCost = 0.1 ether;
    uint balanceToWithdrawPlayer;
    uint timeToReact = 3 minutes;
    uint gameValidUntil;
    uint8 public board_size=3;
    uint8 moveCounter;
    address payable[3][3] Board;
    string displayBoard;
    address payable public player1;
    address payable public player2;
    address payable activePlayer;
    bool gameActive;
    event GameOverWithWin(address Winner);
    event GameOverWithDraw();
    event NextPlayerEvent(address NextPlayer_studentID);
    event PlayerJoined_0858711(address player);
    event PayoutSeccess(address payable receiver, uint amount);

    constructor() public payable {
        player1 = msg.sender;
        // player 1 pay the gameCost
        require(msg.value == gameCost,
                'you need to pay the game cost');
        gameValidUntil = now + timeToReact;
    }

    function joinGame() public payable {
        require(player2 == address(0));
        player2 = msg.sender;
        // player 2 pay the gameCost
        require(msg.value == gameCost,
                'you need to pay the game cost');
        //        string('you need to pay the game cost') + string(gameCost));

        if (block.number %2 == 0) {
            activePlayer = player1;
        } else {
            activePlayer = player2;
        }
        gameValidUntil = now + timeToReact;
        gameActive = true;

        emit PlayerJoined_0858711(msg.sender);
        emit NextPlayerEvent(activePlayer);
    }

    function withdraw_fallback(address payable player) public {
        require(balanceToWithdrawPlayer > 0);
        player.transfer(balanceToWithdrawPlayer);
        emit PayoutSeccess(player, balanceToWithdrawPlayer);
        balanceToWithdrawPlayer = 0;
    }

    function emergencyCashout() public {
        require(gameValidUntil < now);
        require(gameActive);
        setDraw();
    }

    function setWinner(address payable player) private {
        gameActive = false;

        uint balanceToPayOut = address(this).balance;
        if (player.send(balanceToPayOut) != true) {
            balanceToWithdrawPlayer = balanceToPayOut;
            withdraw_fallback(player);
        } else {
            emit PayoutSeccess(player, balanceToPayOut);
        }

        emit GameOverWithWin(player);
        return;
    }

    function setDraw() private {
        gameActive = false;

        emit GameOverWithDraw();
        uint balanceToPayOut = address(this).balance / 2;
        if (player1.send(balanceToPayOut) != true) {
            balanceToWithdrawPlayer = balanceToPayOut;
            withdraw_fallback(player1);
        } else {
            emit PayoutSeccess(player1, balanceToPayOut);
        }

        if (player2.send(balanceToPayOut) != true) {
            balanceToWithdrawPlayer = balanceToPayOut;
            withdraw_fallback(player2);
        } else {
            emit PayoutSeccess(player2, balanceToPayOut);
        }

        return;
    }

    function setStone(uint8 x, uint8 y) public {
        require(gameActive,
                "game has not been active or has been complete");
        require(gameValidUntil > now);
        require(x<board_size && y<board_size,
                "out of board boundary");
        require(msg.sender == player1 || msg.sender == player2,
                "only player1 and player2 can play this round");
        require(Board[x][y] == address(0),
                "this position is occupied");
        require(msg.sender == activePlayer,
                "not your turn");

        Board[x][y] = msg.sender;
        //updateDisplayBoard();

        if (checkWin()) {
            setWinner(activePlayer);
        }

        moveCounter ++;
        if (moveCounter == board_size**2) {
            // draw!
            setDraw();
        } else {
            // modify activePlayer to the other player.
            if (activePlayer == player1) {
                activePlayer = player2;
            } else {
                activePlayer = player1;
            }
            emit NextPlayerEvent(activePlayer);
        }

        gameValidUntil = now + timeToReact;
    }

    // function updateDisplayBoard() {
    //     displayBoard = '';
    //     for (uint8 i=0; i<board_size; i++) {
    //         for (uint8 j=0; j<board_size; j++) {
    //             if (Board[i][j] == player1) {
    //                 displayBoard += " O";
    //             } else if (Board[i][j] == player2) {
    //                 displayBoard += " X";
    //             } else {
    //                 displayBoard += " _";
    //             }
    //         }
    //         displayBoard += "\n";
    //     }
    // }

    function getBoard() public view returns(address payable[3][3] memory) { //string memory
        // return displayBoard;
        return Board;
    }

    // function checkFinished() public view returns(bool) {
    //     for (uint8 i=0; i<board_size; i++) {
    //         for (uint8 j=0; j<board_size; j++) {
    //             if (Board[i][j] == address(0)) {
    //                 return false;
    //             }
    //         }
    //     }
    //     return true;
    // }

    function checkRow(uint8 i) public view returns(bool) {
        for (uint8 j=0; j<board_size; j++) {
            if(Board[i][j] != activePlayer || Board[i][j] == address(0)) {
                return false;
            }
        }
        return true;
    }

    function checkCol(uint8 i) public view returns(bool) {
        for (uint8 j=0; j<board_size; j++) {
            if(Board[j][i] != activePlayer || Board[j][i] == address(0)) {
                return false;
            }
        }
        return true;
    }

    function checkDiag() public view returns(bool) {
        bool flag=true;
        for (uint8 i; i<board_size; i++) {
            if(Board[i][i] != activePlayer) {
                flag = false;
                break;
            }
        }
        if(flag) return true;
        flag = true;
        for (uint8 i; i<board_size; i++) {
            if(Board[i][board_size - 1 - i] != activePlayer) {
                flag = false;
                break;
            }
        }
        if(flag) return true;
    }

    function checkWin() public view returns(bool) {
        for(uint8 i=0; i<board_size; i++) {
            if (checkRow(i) || checkCol(i)) return true;
        }
        if (checkDiag()) return true;
        return false;
    }

    //     return
    // }
}
