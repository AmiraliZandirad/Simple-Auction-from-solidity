// AmiraliZandrad
// SPDX-License-Identifier: GPL-3.0

    pragma solidity >=0.8.5 <0.8.22;

contract Auction {

    address public beneficiary;   

    uint public auctionStartTime;   
    uint public auctionEndTime;   

    uint public highestBid;       
    address public highestBider;  

    mapping(address => uint) pendingRefunds;    

    bool ended;     

    constructor(uint _deadline, address _beneficiary, uint _basePrice) {


        auctionStartTime = block.timestamp;
        auctionEndTime = auctionStartTime + _deadline;

        beneficiary = _beneficiary;

        highestBid = _basePrice;

    }

    modifier isValidTime() {

        require(block.timestamp < auctionEndTime, "Acution Ended!");
        _;
    }

    modifier isHighestBid() {


        require(msg.value > highestBid, "Your BidPrice is ledd than higestBid!");
        _;
    }

 
    function bid() public payable isValidTime isHighestBid {


        pendingRefunds[highestBider] += highestBid;

        highestBid = msg.value;
        highestBider = msg.sender;


    }


    function refund() public returns (bool) {


        uint amount = pendingRefunds[msg.sender];


        require(amount > 0,"Your refund amount is Zero!");


        bool result = pay_Send(payable (msg.sender), amount);

        if(result){ // if (result == true)

            pendingRefunds[msg.sender]= 0;
            return true;
        }else{
            return false;
        }

    }

    function payToBeneficiary() public returns (bool) {


        bool result = pay_Send(payable (beneficiary), highestBid);

        return result;
    }



    function stopAction() public {


        require(auctionEndTime <= block.timestamp ,"Auction can't end this time!");

        ended = true;
    }

    function pay_Send(address payable To, uint amount) public returns(bool) {

        require(amount <= address(this).balance, "No euogh blance!");

  


        bool result = To.send(amount);

        require(result == true , "Failure in payment via Send");


        return result;
    }

}
