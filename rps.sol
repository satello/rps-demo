/**
 *  @title RPS
 *  @author Sam Vitello
 *  This is a simple Rock Paper Scissors game contract.
 *  WARNING This contract has vulnerabilities and is meant for teaching purposes only.
 *  DO NOT use in production.
 */
pragma solidity ^0.4.24;

contract RPS {
    // the addresses of our two players
    address public player1;
    address public player2;
    // the options each player has in the game. NOTE: correspond to values 0,1,2,3
    enum Move {NULL, ROCK, PAPER, SCISSORS}
    // The amount staked by each player
    uint public stake;
    // The selection for each player
    Move private player1Selection;
    Move private player2Selection;

    event NewMove(address player, Move selection);

    modifier onlyPlayer2 {
        require(msg.sender == player2, 'Only player 2 can call this function');
        _;
    }

    constructor(address _player2, Move selection) payable public {
        player1 = msg.sender;
        player2 = _player2;
        stake = msg.value;
        player1Selection = selection;
    }

    function submitSelection(Move selection) payable onlyPlayer2 public {
        require(msg.value == stake, "Must submit the same stake as player 1");
        require(player2Selection == Move.NULL, "You have already made a selection");

        player2Selection = selection;
        emit NewMove(msg.sender, selection);
    }

    function determineWinner() public {
        require(player2Selection > Move.NULL, "Player 2 must have made a selection");
        uint totalStaked = address(this).balance;

        // Tie send the deposit back to each party
        if (player1Selection == player2Selection) {
            // Each player gets half of the ETH in the contract. Floor division
            player1.send(totalStaked / 2);
            player2.send(totalStaked / 2);
        } else if (player1Selection == Move.NULL) {
            // player 1 didn't give a valid selection. Give stake to player 2
            player2.transfer(totalStaked);
        } else if (uint8(player1Selection) % 2 == uint8(player2Selection) % 2) {
            // Must be ROCK, SCISSORS as at this point we have ruled out NULL for both players
            if (player1Selection == Move.ROCK) {
                // Player1 must have ROCK and player2 SCISSORS
                player1.transfer(totalStaked);
            } else {
                // Player2 must have Rock and player1 SCISSORS
                player2.transfer(totalStaked);
            }
        } else {
            // Either have ROCK, PAPER or PAPER, SCISSORS
            if (player1Selection > player2Selection) {
                // ROCK loses to PAPER and PAPER loses to SCISSORS so the higher indexed solution always wins.
                player1.transfer(totalStaked);
            } else {
                player2.transfer(totalStaked);
            }
        }
    }
}
