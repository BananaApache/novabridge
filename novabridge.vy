# A simple Ethereum smart contract for a call option between Party A and Party B

@version ^0.3.9

# State variables
partyA: public(address)
partyB: public(address)
optionPrice: public(wei_value)
strikePrice: public(wei_value)
endDate: public(timestamp)
exercised: public(bool)

# Event Logs
event OptionSold:
    seller: indexed(address)
    buyer: indexed(address)
    price: wei_value

event OptionExercised:
    buyer: indexed(address)
    amountPaid: wei_value

event OptionReturned:
    seller: indexed(address)

# Constructor: Initialize the contract with Party A's details
@external
def __init__(_partyA: address, _optionPrice: wei_value, _strikePrice: wei_value, _endDate: timestamp):
    assert _endDate > block.timestamp, "End date must be in the future"
    
    self.partyA = _partyA
    self.optionPrice = _optionPrice
    self.strikePrice = _strikePrice
    self.endDate = _endDate
    self.exercised = False

# Sell option to Party B
@external
@payable
def sellOption(_partyB: address):
    assert msg.value == self.optionPrice, "Incorrect payment amount"
    assert self.partyB == empty(address), "Option already sold"
    
    self.partyB = _partyB
    log OptionSold(self.partyA, self.partyB, msg.value)

# Party B exercises the option before expiration
@external
@payable
def exerciseOption():
    assert msg.sender == self.partyB, "Only the option holder can exercise"
    assert block.timestamp <= self.endDate, "Option has expired"
    assert msg.value == self.strikePrice, "Incorrect strike price"
    assert not self.exercised, "Option already exercised"

    self.exercised = True
    send(self.partyA, msg.value)  # Pay Party A the strike price
    send(self.partyB, self.optionPrice)  # Refund Party B the option price
    log OptionExercised(self.partyB, msg.value)

# Return option to Party A if not exercised before the deadline
@external
def returnOption():
    assert block.timestamp > self.endDate, "Option is still active"
    assert not self.exercised, "Option already exercised"
    assert self.partyB != empty(address), "Option was not sold"

    send(self.partyA, self.optionPrice)  # Return the option price to Party A
    log OptionReturned(self.partyA)
