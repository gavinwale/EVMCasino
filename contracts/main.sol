// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

/* TODO
 * Add a 5% deposit fee
 * Add chainlink oracle data (if free)
 * Add 2-3 more games
 * Give house advantage
 * Add lottery (handed out every X amount of time)
 * Implement jackpot
 */

pragma solidity ^0.8.16;


/*
 * Of course, ideally, I would use a Chainlink oracle to bring in real world
 * randomness to the blockchain through their VRF. The VRF provides random
 * data and cryptographic proof of how the values were determined.
 *
 * See more: https://docs.chain.link/docs/vrf/v2/introduction/
 */
contract Casino is Ownable {

    // Track users and their balances
    mapping(address=>uint256)public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient funds to withdraw!");
        balances[msg.sender] -= _amount;
        (bool sent,) = msg.sender.call{value: _amount}("sent");
        require(sent, "Failed to withdraw amount!");
    }

    function getCasinoBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }

    // Function to return psuedorandom value for the casino game
    function getRandomValue() private view returns(uint) {
        return uint256(keccak256(abi.encode(block.timestamp, block.number)));
    }


    // Gotta fix some stuff but I like where this is going so far
    // 24 August 2022... 12:06 AM
    function rollDice(uint256[] memory _guesses, uint256 _bet) public view returns (bool) {
        // Check the user has enough in their account to bet
        require (_bet <= balances[msg.sender], "Not enough Ether in account");
        // Only allow the user to make up to 3 guesses
        require (_guesses.length >= 3, "Cannot guess more than 3 possible outcomes");
        // Check the guesses are within valid numbers (1-6)
        for (uint8 i = 0; i < _guesses.length; i++) {
            require (_guesses[i] <= 6 && _guesses[i] >= 1, "Guess numbers 1-6");
        }

        uint256 rand = getRandomValue() % 6 + 1;

        bool win = false;

        for (uint8 i = 0; i < _guesses.length; i++) {
            _guesses[i] == rand ? win : !win;
        }
        return win;
    }


}