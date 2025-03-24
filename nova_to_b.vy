# Contract between NovaSpy and PartyB (the buyer)
#pragma version >0.3.10

# State variables
partyA: public(address)
partyB: public(address)
NovaSpy: public(address) # Our own address
optionPrice: public(uint256)
strikePrice: public(uint256)
endDate: public(uint256)
exercised: public(bool)
bought: public(bool)

# Event Logs
event OptionSold:
    buyer: indexed(address)
    seller: indexed(address)
    price: uint256
    strike: uint256

event OptionExercised:
    buyer: indexed(address)
    seller: indexed(address)
    amountPaid: uint256

# Buyer initializes contract with us
@deploy
def __init__(_partyB: address, _strikePrice: uint256, _endDate: uint256):
    assert _endDate > block.timestamp, "End date must be in the future"
    
    self.partyB = _partyB
    self.strikePrice = _strikePrice
    self.endDate = _endDate
    self.exercised = False
    self.bought = False

# After a buyer inits a contract:
# We set the option price, provide an address we own, and set a seller
@external
def setOption(_NovaSpy: address, _partyA: address, _optionPrice: uint256):
    assert block.timestamp < self.endDate, "Option has expired"
    assert self.optionPrice == empty(uint256), "Option Price already set"

    self.optionPrice = _optionPrice
    self.partyA = _partyA
    self.NovaSpy = _NovaSpy

# Once a seller pays us the strike price we have the buyer pay us the option price
@payable
@external
def buyOption():
    assert self.bought == False, "Option already bought"
    assert self.partyA != empty(address), "Seller not set"
    assert block.timestamp < self.endDate, "Option has expired"
    assert msg.sender == self.partyB, "Buyer address discrepancy"
    assert msg.value == self.optionPrice, "Option price does not match"

    send(self.NovaSpy, msg.value)
    self.bought = True

    log OptionSold(msg.sender, self.partyA, msg.value, self.strikePrice)

# Allows the buyer to exercise the option
@payable
@external
def exerciseOption():
    assert self.bought == True, "No option has been bought"
    assert self.exercised == False, "Option has already been exercised"
    assert block.timestamp < self.endDate, "Option has expired"
    assert msg.sender == self.NovaSpy, "Wrong address for this contract"
    assert msg.value == self.strikePrice, "Strike price does not match"

    send(self.partyB, msg.value)
    self.exercised = True

    log OptionExercised(self.partyB, self.partyA, msg.value)