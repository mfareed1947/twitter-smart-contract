// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract twitter {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 creationTime;
    }
    struct Message {
        uint256 id;
        address sender;
        address receiver;
        string message;
        uint256 creationTime;
    }

    uint256 public nextUserId;
    uint256 public nextMessageId;

    mapping(uint256 => Tweet) tweets;
    mapping(address => uint256[]) tweetOf;
    mapping(address => Message[]) conversations;
    mapping(address => mapping(address => bool)) operators;
    mapping(address => address[]) following;

    function _tweet(address _from, string memory content) internal {
        require(
            _from == msg.sender && operators[_from][msg.sender],
            "You don't have access"
        );
        tweets[nextUserId] = Tweet(nextUserId, _from, content, block.timestamp);
        tweetOf[_from].push(nextUserId);
        nextUserId++;
    }

    function _sendMessage(
        address _from,
        address _to,
        string memory content
    ) internal {
        require(
            _from == msg.sender && operators[_from][msg.sender],
            "You don't have access"
        );
        conversations[_from].push(
            Message(nextMessageId, _from, _to, content, block.timestamp)
        );
        nextMessageId++;
    }

    function tweet(string memory content) public {
        // owner Tweet
        _tweet(msg.sender, content);
    }

    function tweet(address _from, string memory content) public {
        //Account handler Tweet
        _tweet(_from, content);
    }

    function sendMessage(
        address _from,
        address _to,
        string memory content
    ) public {
        //Account Handler message
        _sendMessage(_from, _to, content);
    }

    function sendMessage(string memory content, address _to) public {
        //Owner message
        _sendMessage(msg.sender, _to, content);
    }

    function follow(address _followed) public {
        following[msg.sender].push(_followed);
    }

    function allow(address _operator) public {
        operators[msg.sender][_operator] = true;
    }

    function disallow(address _operator) public {
        operators[msg.sender][_operator] = false;
    }

    function getLatestTweets(uint256 count)
        public
        view
        returns (Tweet[] memory)
    {
        require(count > 0 && count <= nextUserId, "count is not proer");
        Tweet[] memory _tweets = new Tweet[](count);

        uint256 j;
        for (uint256 i = nextUserId - count; i < nextUserId; i++) {
            Tweet storage _strcture = tweets[i];
            _tweets[j] = Tweet(
                _strcture.id,
                _strcture.author,
                _strcture.content,
                _strcture.creationTime
            );
            j++;
        }
        return _tweets;
    }

    function getlatestTweetOfUser(address _user, uint256 count)
        external
        view
        returns (Tweet[] memory)
    {
        Tweet[] memory _tweets = new Tweet[](count);
        uint256[] memory ids = tweetOf[_user];
        require(count > 0 && count <= nextUserId, "count is not proer");
        uint256 j;
        for (uint256 i = ids.length - count; i < ids.length; i++) {
            Tweet storage _strcture = tweets[ids[i]];
            _tweets[j] = Tweet(
                _strcture.id,
                _strcture.author,
                _strcture.content,
                _strcture.creationTime
            );
            j++;
        }
        return _tweets;
    }
}
