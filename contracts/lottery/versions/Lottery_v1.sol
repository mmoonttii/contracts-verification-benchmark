// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >= 0.8.2;

/// @custom:version conformant to specification
contract Lottery {
    address public owner;

    address payable player0;
    address payable player1; 
    address payable winner;

    bytes32 hash0;
    bytes32 hash1;

    string secret0;
    string secret1;

    uint256 bet_amount;

    enum Status {
        Join0,
        Join1,
        Commit0,
        Commit1,
	    Reveal0,
	    Reveal1,
	    Win,
        End
    }

    uint end_join;
    uint end_reveal;
    
    Status public status;
    
    uint constant DELTA_TIME = 1000;
    uint constant MINIMUM_BET = 0.01 ether;

    constructor() {
        owner = msg.sender;
	    status = Status.Join0;
	    end_join = block.number + DELTA_TIME;
	    end_reveal = end_join + DELTA_TIME;
    }

    /// `player1` joins the lottery by paying the bet and committing to a secret
    function join0(bytes32 h) payable public {
        require (status==Status.Join0);
        require (msg.value > MINIMUM_BET);

        player0 = payable(msg.sender);
        hash0 = h;
	    status = Status.Join1;
        bet_amount = msg.value;
    }

    /// `player2` joins the lottery by paying the bet and committing to another secret (the bet is the same for each player)
    function join1(bytes32 h) payable public {
        require (status==Status.Join1);
        require (h!=hash0);
        require (msg.value == bet_amount);

        player1 = payable(msg.sender);
        hash1 = h;	
    	status = Status.Reveal0;
    }

    /// if `player2` has not joined, `player1` can redeem their bet after a given deadline (`end_commit`).
    function redeem0_nojoin1() public {
	    require (status==Status.Join1);
        require (block.number > end_join);

        (bool success,) = player0.call{value: address(this).balance}("");
        require (success, "Transfer failed.");
	    status = Status.End;
    } 
    
    /// `player1` reveals the first secret
    function reveal0(string memory s) public {
        require (status==Status.Reveal0);
        require (msg.sender==player0);
        require(keccak256(abi.encodePacked(s))==hash0);

        secret0 = s;
	    status = Status.Reveal1;
    }

    /// if `player1` has not revealed, `player2` can redeem both players' bets after a given deadline (`end_reveal`); 
    function redeem1_noreveal0() public {
	    require (status==Status.Reveal0);
        require (block.number > end_reveal);

        (bool success,) = player1.call{value: address(this).balance}("");
        require (success, "Transfer failed.");
	    status = Status.End;
    } 
    
    /// once `player1` has revealed, `player2` reveals the secret
    function reveal1(string memory s) public {
        require (status==Status.Reveal1);
        require (msg.sender==player1);
        require(keccak256(abi.encodePacked(s))==hash1);

        secret1 = s;
	    status = Status.Win;
    }

    /// if `player2` has not revealed, `player1` can redeem both players' bets after a given deadline (`end_reveal` plus a fixed constant)
    function redeem0_noreveal1() public {
	    require (status==Status.Reveal1);
        require (block.number > end_reveal);

        (bool success,) = player0.call{value: address(this).balance}("");
        require (success, "Transfer failed.");
	    status = Status.End;
    } 
    
    /// once both secrets have been revealed, the winner, who is fairly determined as a function of the two revealed secrets, can redeem the whole pot
    function win() public {
        require (status==Status.Win);
	
        uint256 l0 = bytes(secret0).length;
        uint256 l1 = bytes(secret1).length;

        if ((l0+l1) % 2 == 0)  winner = player0;
        else winner = player1;

        (bool success,) = winner.call{value: address(this).balance}("");
        require (success, "Transfer failed.");
	    status = Status.End;
    }
}
