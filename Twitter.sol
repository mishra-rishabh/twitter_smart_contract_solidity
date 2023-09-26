// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    function getProfile(address _user) external view returns (UserProfile memory);
}

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

    IProfile profileContract;

    event TweetCreated(uint id, address author, string content, uint timestamp);
    event TweetLiked(address liker, address tweetAuthor, uint tweetId, uint newLikeCount);
    event TweetUnliked(address unLiker, address tweetAuthor, uint tweetId, uint newLikeCount);

    constructor(address _profileContract) {
        owner = msg.sender;

        profileContract = IProfile(_profileContract);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    modifier onlyRegistered() {
        IProfile.UserProfile memory userProfileTemp = profileContract.getProfile(msg.sender);

        require(bytes(userProfileTemp.displayName).length > 0, "User not registered!");
        _;
    }

    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }

    function createTweet(string memory _tweet) public onlyRegistered {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long!");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);

        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp);
    }

    function likeTweet(address author, uint id) external onlyRegistered {
        require(tweets[author][id].id == id, "Tweet doesn't exist!");

        tweets[author][id].likes++;

        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }

    function unlikeTweet(address author, uint id) external onlyRegistered {
        require(tweets[author][id].id == id, "Tweet doesn't exist!");
        require(tweets[author][id].likes > 0, "Tweet has no likes!");

        tweets[author][id].likes--;

        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    function getTweet(uint _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }

    function getTotalLikes(address _author) external view returns (uint) {
        uint totalLikes;

        for(uint i = 0; i < tweets[_author].length; i++) {
            totalLikes += tweets[_author][i].likes;
        }

        return totalLikes;
    }
}