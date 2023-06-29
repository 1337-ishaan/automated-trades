pragma solidity ^0.8.0;

contract AutomatedTrade {
    enum TradeStatus { Open, Completed, Cancelled }

    struct Trade {
        address initiator;
        address counterparty;
        uint256 amount;
        TradeStatus status;
    }

    mapping(address => Trade[]) public userTrades;

    event TradeOpened(address indexed initiator, address indexed counterparty, uint256 amount);
    event TradeCompleted(address indexed initiator, address indexed counterparty, uint256 amount);
    event TradeCancelled(address indexed initiator, address indexed counterparty, uint256 amount);

    function openTrade(address counterparty, uint256 amount) external {
        require(counterparty != msg.sender, "Cannot trade with yourself");

        Trade memory newTrade = Trade({
            initiator: msg.sender,
            counterparty: counterparty,
            amount: amount,
            status: TradeStatus.Open
        });

        userTrades[msg.sender].push(newTrade);
        userTrades[counterparty].push(newTrade);

        emit TradeOpened(msg.sender, counterparty, amount);
    }

    function completeTrade(address initiator, uint256 tradeIndex) external {
        Trade[] storage trades = userTrades[initiator];
        require(tradeIndex < trades.length, "Invalid trade index");

        Trade storage trade = trades[tradeIndex];
        require(trade.counterparty == msg.sender, "Only the counterparty can complete the trade");
        require(trade.status == TradeStatus.Open, "Trade is not open");

        // Transfer tokens
        // You need to implement the transfer logic for your specific ERC20 token

        trade.status = TradeStatus.Completed;

        emit TradeCompleted(initiator, msg.sender, trade.amount);
    }

    function cancelTrade(address initiator, uint256 tradeIndex) external {
        Trade[] storage trades = userTrades[initiator];
        require(tradeIndex < trades.length, "Invalid trade index");

        Trade storage trade = trades[tradeIndex];
        require(trade.initiator == msg.sender, "Only the initiator can cancel the trade");
        require(trade.status == TradeStatus.Open, "Trade is not open");

        trade.status = TradeStatus.Cancelled;

        emit TradeCancelled(initiator, trade.counterparty, trade.amount);
    }
}
