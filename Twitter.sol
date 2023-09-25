// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Twitter {
    uint16 public MAX_TWEET_LENGTH = 300;

    struct Tweet {
        uint id;
        address author;
        string content;
        uint timestamp;
        uint likes;
    }

    mapping(address => Tweet[]) public tweets;

    address public owner;

    constructor() {
        owner = msg.sender;

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }

    function createTweet(string memory _tweet) public {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long!");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);
    }

    function likeTweet(address author, uint id) external {
        require(tweets[author][id].id == id, "Tweet doesn't exist!");

        tweets[author][id].likes++;
    }

    function unlikeTweet(address author, uint id) external {
        require(tweets[author][id].id == id, "Tweet doesn't exist!");
        require(tweets[author][id].likes > 0, "Tweet has no likes!");

        tweets[author][id].likes--;
    }

    function getTweet(uint _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }
}