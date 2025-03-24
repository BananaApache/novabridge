# Contract between NovaSpy and PartyA (the seller)
#pragma version >0.3.10

# State variables
partyA: public(address)
partyB: public(address)
NovaSpy: public(address) # Our own address
optionPrice: public(uint256)
strikePrice: public(uint256)
endDate: public(uint256)
exercised: public(bool)
sold: public(bool)
strikeSent: public(bool)

# Event Logs
event StrikeSent:
    seller: indexed(address)
    nsAddress: indexed(address)
    strike: uint256

event OptionSold:
    buyer: indexed(address)
    seller: indexed(address)
    price: uint256
    strike: uint256

event OptionExercised:
    buyer: indexed(address)
    seller: indexed(address)
    amountPaid: uint256

event OptionExpired:
    seller: indexed(address)
    strike: uint256

# Seller initializes contract with us
@deploy
def __init__(_partyA: address, _strikePrice: uint256, _endDate: uint256):
    assert _endDate > block.timestamp, "End date must be in the future"
    
    self.partyA = _partyA
    self.strikePrice = _strikePrice
    self.endDate = _endDate
    self.exercised = False
    self.sold = False
    self.strikeSent = False

# After a seller inits a contract:
# We set the option price, provide an address we own, and set a buyer
@external
def setOption(_NovaSpy: address, _partyB: address, _optionPrice: uint256):
    assert block.timestamp < self.endDate, "Option has expired"
    assert self.optionPrice == empty(uint256), "Option Price already set"

    self.optionPrice = _optionPrice
    self.partyB = _partyB
    self.NovaSpy = _NovaSpy

# This function allows the seller to pay us the strike price
@payable
@external
def sendStrike():
    assert self.strikeSent == False, "Strike price already sent"
    assert self.partyB != empty(address), "Buyer not set"
    assert block.timestamp < self.endDate, "Option has expired"
    assert msg.sender == self.partyA, "Seller address discrepancy"
    assert msg.value == self.strikePrice, "Incorrect strike price"

    send(self.NovaSpy, msg.value)
    self.strikeSent = True
    
    log StrikeSent(msg.sender, self.NovaSpy, msg.value)

# Pays the seller the option price
@payable
@external
def payBuyer():
    assert self.strikeSent == True, "Strike has not been sent"
    assert self.sold == False, "Option already sold"
    assert msg.sender == self.NovaSpy, "Wrong address for this contract"
    assert msg.value == self.optionPrice, "Option price does not match"

    send(self.partyA, msg.value)
    self.sold = True

    log OptionSold(self.partyB, self.partyA, self.optionPrice, self.strikePrice)

# Sets the option as exercised
@external
def setExercised():
    assert self.sold == True, "No option has been sold"
    assert self.exercised == False, "Option has already been exercised"
    assert block.timestamp < self.endDate, "Option has expired"

    self.exercised = True

    log OptionExercised(self.partyB, self.partyA, self.strikePrice)

# If the option expires we return the strike price to the seller
@payable
@external
def returnStrike():
    assert block.timestamp > self.endDate, "Option has not expired"