pragma solidity >=0.5.1;
contract CrowdFunding{

    uint deadline;
    uint fundingGoal;
    uint public totalAmount;
    uint8 investorIdx;
    address payable public contracOwner;
    modifier onlyOwner {
        require(msg.sender == contracOwner);
        _;
    }

    struct Investor {
        address payable addr;
        uint amount;
    }
    mapping(uint8 => Investor) public Investors;

    bool isFundAvailable = false;

    event FundingStatus(string message);
    event PayoutSeccess(address payable receiver, uint amount);

    constructor(uint duration, uint goal) public {

        contracOwner = msg.sender;
        deadline = now + duration;
        fundingGoal = goal;
        isFundAvailable = true;
        investorIdx = 0;
        totalAmount = 0;
    }

    function Fund() public payable {
        require(isFundAvailable, "Funding is not available.");

        Investors[investorIdx].addr = msg.sender;
        Investors[investorIdx].amount = msg.value;

        totalAmount += msg.value;
        investorIdx += 1;
    }

    function checkGoalReached() public onlyOwner {
        //require(isFundAvailable, "[in check func.] Fund is unavailable");
        if (isFundAvailable == false) {
            // not available
            revert();
        }
        require(now > deadline, "the deadline hasn't been reached.");

        address payable addr;
        uint amount;

        // check
        if (totalAmount >= fundingGoal) {
            // funding success
            emit FundingStatus("Funding Successed");

            // send all money to funding owner.
            if (contracOwner.send(totalAmount) != true) {
                revert();
            } else {
                emit PayoutSeccess(contracOwner, totalAmount);

            }
        } else {
            //funding fail
            emit FundingStatus("Funding Failed");

            // return money to all investors
            for (uint8 i=0; i<investorIdx; i++) {
                addr = Investors[i].addr;
                amount = Investors[i].amount;
                if(addr.send(amount) != true) {
                    revert();
                } else {
                    emit PayoutSeccess(addr, amount);
                }
            }
        }
    }
}
