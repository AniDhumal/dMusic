//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 < 0.9.0;
import "./Splits.sol";

contract RoyaltyPay is Splits{

    address splitsContract;
    constructor(address _splitsContract){
        splitsContract=_splitsContract;
    }

    event ethTransferedForSplit(uint amount, address receiver, uint _tokenId);

    function splitMonthlyRevenue(uint _tokenId) payable ownedBy(_tokenId) public {//sends ether in msg.value 

        Splits s= Splits(splitsContract);
        Cont[] memory cont;
        uint forToken=s.Contributors(msg.sender).forToken;
        for(uint i=0; i<=cont.length-1;i++){
            if(cont[i].forToken==_tokenId){
                uint256 amount=(msg.value/100)*cont[i].contSplit.split;//use safe math 
                uint256 contractCut=(amount/1000)*2;
                amount=amount-contractCut;
                address receiver;
                payable(receiver).transfer(amount);
                emit ethTransferedForSplit(amount, receiver, _tokenId);
            }
        }
        
    }

}