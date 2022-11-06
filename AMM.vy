from vyper.interfaces import ERC20

tokenAQty: public(uint256) #Quantity of tokenA held by the contract
tokenBQty: public(uint256) #Quantity of tokenB held by the contract

invariant: public(uint256) #The Constant-Function invariant (tokenAQty*tokenBQty = invariant throughout the life of the contract)
tokenA: ERC20 #The ERC20 contract for tokenA
tokenB: ERC20 #The ERC20 contract for tokenB
owner: public(address) #The liquidity provider (the address that has the right to withdraw funds and close the contract)

@external
def get_token_address(token: uint256) -> address:
	if token == 0:
		return self.tokenA.address
	if token == 1:
		return self.tokenB.address
	return ZERO_ADDRESS	

# Sets the on chain market maker with its owner, and initial token quantities
@external
def provideLiquidity(tokenA_addr: address, tokenB_addr: address, tokenA_quantity: uint256, tokenB_quantity: uint256):
	assert self.invariant == 0 #This ensures that liquidity can only be provided once
	#Your code here
	self.owner = msg.sender # The sender corresponds to the address which provides liquidity (and therefore is the owner)
	self.tokenA = ERC20(tokenA_addr) # Both tokenA_addr and tokenB_addr should be addresses of valid ERC20 contracts, 
	self.tokenB = ERC20(tokenB_addr)
	self.tokenAQty = tokenA_quantity # and tokenA_quantity and tokenB_quantity should be the quantities of each token that are being deposited. 
	self.tokenBQty = tokenB_quantity
	self.tokenA.transferFrom(msg.sender, self, tokenA_quantity) # token transfer with the quantity of tokenA_quantity and tokenB_quantity
	self.tokenB.transferFrom(msg.sender, self, tokenB_quantity)
	self.invariant = self.tokenAQty * self.tokenBQty # tokenAQty*tokenBQty = invariant throughout the life of the contract

	assert self.invariant > 0

# Trades one token for the other
# tradeTokens(sell_token, sell_quantity)
# sell_token should match either tokenA_addr or tokenB_addr, and sell_quantity should be the amount of that token being traded to the contract. 
# The contract should calculate the amount of the other token to return to the sender using the invariant calculation of Uniswap.
@external
def tradeTokens(sell_token: address, sell_quantity: uint256):
	assert sell_token == self.tokenA.address or sell_token == self.tokenB.address
	#Your code here
	if sell_token == self.tokenA.address: # if the sell_token matches with tokenA_addr
		self.tokenA.transferFrom(msg.sender, self, sell_quantity)
		self.tokenAQty = self.tokenAQty + sell_quantity # tokenAQty to be updated
		# self.tokenA.transfer(self, self.tokenAQty)
		# sellBQty: uint256 = self.invariant / sell_quantity
		# self.tokenBQty = self.tokenBQty - invariant / sell_quantity
		# self.tokenB.transfer (msg.sender, sellBQty)
		self.tokenBQty = self.tokenBQty - sell_quantity
		# self.tokenBQty = self.tokenBQty + self.invariant / sell_quantity
		# self.tokenB.transfer (self, self.tokenBQty)
		# self.tokenB.transfer(self, sell_quantity)
		# self.tokenB.transferFrom(msg.sender, self, sell_quantity)

	elif sell_token == self.tokenB.address: # sell_token matches with tokenB_addr
		self.tokenB.transferFrom(msg.sender, self, sell_quantity)
		self.tokenBQty = self.tokenBQty + sell_quantity
		# self.tokenB.transfer(self, self.tokenBQty)

		# sellAQty: uint256 = self.invariant / sell_quantity
		self.tokenA.transfer (msg.sender, sellAQty)
		self.tokenAQty = self.tokenAQty - sell_quantity








		# self.tokenAQty = self.tokenAQty + self.invariant / sell_quantity
		# self.tokenA.transfer (self, self.tokenAQty)
		# self.tokenA.transfer(self, sell_quantity)
		# self.tokenA.transferFrom(msg.sender, self, sell_quantity)

# Owner can withdraw their funds and destroy the market maker
# ownerWithdraw()
# If the message sender was the initial liquidity provider, this should give all tokens held by the contract to the message sender, otherwise it should fail.
@external
def ownerWithdraw():
	assert self.owner == msg.sender
	#Your code here
	self.tokenA.transfer(self.owner, self.tokenAQty) # transfer all the tokenA to msg sender
	self.tokenB.transfer(self.owner, self.tokenBQty) # transfer all the tokenB to msg sender
	selfdestruct(self.owner)


