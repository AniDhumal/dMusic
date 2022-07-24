//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.7;
// import "@OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@OpenZeppelin/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Splits is ERC721("dMusic","DM"){

	using SafeMath for uint256;

	address owner;
	
	struct Split{
		address contributor;
		uint split;
	}
	

	mapping(uint256=>Split[]) public Contributors;//tokenId to Split 
	// mapping(uint=>address) public tokenToOwner; //implementation from Erc721
	// mapping(uint=>bool) public  tokenExist; //implementation from ERC721
	mapping(string=>bool) public artistExists;
	mapping(string=>address) public artistNames;
	mapping(uint256=>uint256) public tokenSplitTotal; //maps tokenid to the total percent assigned to it 

	event songTokenCreated(string songname, string artistname, uint256 tokenId);
	event artistAdded(string artistname, address artistAddress);
	event ethTransferedForSplit(uint amount, address receiver, uint _tokenId);

	modifier ownedBy(uint _tokenId){
		require(msg.sender==ownerOf(_tokenId));
		_;
	}
	modifier ownerContract(){
		require(msg.sender==owner,"Not an owner of the contract");
		_;
	}

	constructor() public {
		owner=msg.sender;
	}

	function isAContributor(address _from, uint _tokenId) view private returns(bool,uint){
		require(msg.sender==_from,"Request sender and contributor address do not match");
		Split[] memory Conts=Contributors[_tokenId];
		for(uint i=0;i<=Conts.length-1;i++){
			if(Conts[i].contributor==_from){
				return (true,i);
			}
		}
		return (false,0);
	}

	
	function addContributor(address _contributor, uint _tokenId, uint _split) public ownedBy(_tokenId) {
		splitNotExceeding100(_tokenId,_split);//calls a view function and checks if splits are exceeding 100%
		Split memory newSplit;
		newSplit.contributor=_contributor;
		newSplit.split=_split;
		Contributors[_tokenId].push(newSplit);
		tokenSplitTotal[_tokenId]=tokenSplitTotal[_tokenId].add(_split);


	}
	function createSongToken(string memory _songname, string memory  _artistname, uint _selfSplit) public returns(uint256){
		//could use chainlink oracle for generating random number but keccak is used here instead 
		uint256 resultId=uint256(keccak256(abi.encodePacked(_songname, ' ', _artistname)));
		require(_exists(resultId)==false);
		require(artistNames[_artistname]==msg.sender);
		_mint(msg.sender,resultId);

		//adding the artist as a 1st contributor
		Split memory ownerSplit;
		ownerSplit.contributor=msg.sender;
		ownerSplit.split=_selfSplit;
		Contributors[resultId].push(ownerSplit);
		tokenSplitTotal[resultId]=tokenSplitTotal[resultId].add(_selfSplit);


		emit songTokenCreated(_songname,_artistname,resultId);
		return resultId;
	}

	function addNewArtist(string memory _artistname) public  {
		require(artistExists[_artistname]!=true);
		artistNames[_artistname]=msg.sender;
		artistExists[_artistname]=true;
		emit artistAdded(_artistname,msg.sender);
	}

	function splitNotExceeding100(uint _tokenId,uint _split) private view{
		require(tokenSplitTotal[_tokenId].add(_split)<=100);
	}

// Payment Part of the contract
//Done in the same contract because solidity can't return dynamic arrays yet 
	

    function splitMonthlyRevenue(uint _tokenId) payable ownedBy(_tokenId) public {//sends ether in msg.value 
        Split[] memory cont=Contributors[_tokenId];
        for(uint i=0; i<=cont.length-1;i++){
                uint256 amount=(msg.value.div(100)).mul(cont[i].split);//use safe math 
                uint256 contractCut=(amount.div(1000));
                amount=amount.sub(contractCut);
                address receiver=cont[i].contributor;
                payable(receiver).transfer(amount);
                emit ethTransferedForSplit(amount, receiver, _tokenId);
        }
        
    }

	function transferToken(address _from, address _to, uint256 _tokenId) public ownedBy(_tokenId) {
		transferFrom(_from,_to,_tokenId);
	}

	function transferSplits(address _from, address _to, uint256 _tokenId, uint256 _percentOfWhole) public {
		bool isACont;
		uint at;
		(isACont,at)=isAContributor(_from,_tokenId);
		require(isACont,"Not a Verified Contributor");
		Split[] memory cont= Contributors[_tokenId];
		require(_percentOfWhole<=cont[at].split);
		cont[at].split=cont[at].split.sub(_percentOfWhole);
		addContributor(_to,_tokenId,_percentOfWhole);
	}

	//add cash out function for contract owner
	function cashOut() ownerContract payable external{
		payable(owner).transfer(address(this).balance);
	}

	function getContributors(uint256 _tokenId) public view returns(address[] memory arrContributors){
		Split[] memory cont= Contributors[_tokenId];
		for(uint i=0;i<=cont.length-1;i++){
			arrContributors[i]=(cont[i].contributor);
		}
	}

	
		
}


