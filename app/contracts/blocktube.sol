/// @title Blocktu.be contract.

//import "./blocktubeClip.sol";

contract blockTube {

	address owner;
	string public name;
    string public symbol;
    uint8 public decimals;
    uint public numClips;
    uint256 public totalSupply;
	mapping(address => uint256) public balanceOf;
    Clip[] public clips;

    struct Clip {
        address clip;
        string title;
        string description;
        string tags;
    }

	/* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    function blockTube(uint256 _initialSupply, string _tokenName, uint8 _decimalUnits, string _tokenSymbol){
    	balanceOf[msg.sender] = _initialSupply;              // Give the creator all initial tokens
        totalSupply = _initialSupply;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        numClips = 0;
    }

    /* Receive a like and do something with it */
    function like(address _clipaddr, uint256 _value){
    	var clipcontract = blocktubeClip(_clipaddr);
    	clipcontract.blocktubeTransfer(msg.sender, _value);
    }

	/* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    function addclip(address _clip, string _title, string _description, string _tags) {
        
        clips.push(Clip({clip: _clip, title: _title, description: _description, tags: _tags}));

        numClips = clips.length;
    }
}


/// @title [TESTNET] Blocktu.be user contract.

/* 

    Blocktube has two tokens:
    a/ The BTToken
    b/ The ClipToken

    A blocktube clip has a limited supply of tokens (cliptoken).
    The ClipTokens are created by depositing BTToken ('like').
    
    After a certain treshold is met (end of the minting / crowdsale), 
    the next BTTokens (likes) will be distributed amongst 
    the token holders, in relation to the amount 
    of ClipTokens they hold.

*/

// we add the token contract so later, it knows what to do.
//contract token { 
//    function transfer(address receiver, uint amount){} 
//}

contract blocktubeClip {
    
    // First, we need to declare some variables used in this contract.
    // The address of the original poster
    address public owner;

    // the clip is published ? ( AKA visible in index )
    bool public published;

    // The percentage of shares the original poster is willing to trade
    uint public treshold;

    // The contract of the Blocktube token contract
    //token public Token;
    
    // The address of the Blocktube token contract
    address public tokenaddr;

    // The total of shareholders
    uint public shareholdersnum;

    // How much shares the owner has
    uint public percentageforowner;

    // The remaining supply of clipshares
    uint public remainingCliptokens;

    // Every clip has a json object, that's stored on IPFS.
    string public ipfsclipobject;
    
    // We have an array of 'funders', the early likes.
    Shareholder[] public shareholders;    
    // The shareholder object
    struct Shareholder {
        address addr;
        uint shares;
    }

    // Then we define some events, where our contraclistener can listen to.
    //event tresholdReached(likesBalance);

    // And now, the function that runs when deploying this contract.
    function blocktubeClip(string _ipfsclipobject, uint _treshold, uint _percentageforowner){
        owner = msg.sender;
        treshold = _treshold;
        ipfsclipobject = _ipfsclipobject;
        percentageforowner = _percentageforowner;
        shareholders[shareholders.length++] = Shareholder({addr: msg.sender, shares: _percentageforowner});
        remainingCliptokens = 100 - _percentageforowner;
        shareholdersnum = shareholders.length;
        published = false;
        //testnet blocktube contract
        //tokenaddr = 0xc6305f2c2f05e691cD973B3bb610CA9AE9a30720;
    }

    function publish(){
        if (owner != msg.sender) return;
        published = true;
    }

    function unpublish(){
        if (owner != msg.sender) return;
        published = false;
    }

    // When someone sends a like token to this contract's balance in the token contract,
    // the tokencontract will call this function
    function blocktubeTransfer(address _liker, uint _likeamount){
        // When the current amount of shareholders is lower than the treshold,
        // add the msg.sender to shareholders, and give him the amount of
        // shares left / number of shareholders.
        if(shareholders.length <= treshold){
            uint shares = remainingCliptokens / 2;
            uint shareId = shareholders.length++;
            shareholders[shareId] = Shareholder({addr: _liker, shares: shares});
            remainingCliptokens = remainingCliptokens - shares;
        } else {
            // When we have reached the treshold, the likeamount is spread over the shareholders.
            // We invoke the token contract's function 'transfer'
            //for (uint i = 0; i < shareholders.length; i++) {
            //    Token.transfer(shareholders[i].addr, (_likeamount / 100 * shareholders[i].shares)); 
            //}
        }
    }

    // And because my mist wallet is getting full, we need a suicide function.
    function kill() { if (msg.sender == owner) suicide(owner); }



}