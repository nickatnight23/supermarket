
const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("Supermarket", function() {
    it("Should create and execute five grocery sales", async function() {
      /* deploy the marketplace */
      const SuperMarket = await ethers.getContractFactory("SuperMarket")
      const superMarket = await SuperMarket.deploy()
      await superMarket.deployed()
  
      let listingPrice = await superMarket.getListingPrice()
      listingPrice = listingPrice.toString()
  
      const groceryPrice = ethers.utils.parseUnits('1', 'ether')
     
      /* create five groceries */
      await superMarket.createGrocery("https://www.mygrocery1.com", groceryPrice, { value: listingPrice })
      await superMarket.createGrocery("https://www.mygrocery2.com", groceryPrice, { value: listingPrice })
      await superMarket.createGrocery("https://www.mygrocery3.com", groceryPrice, { value: listingPrice })
      await superMarket.createGrocery("https://www.mygrocery4.com", groceryPrice, { value: listingPrice })
      await superMarket.createGrocery("https://www.mygrocery5.com", groceryPrice, { value: listingPrice })

        
      accounts = await ethers.getSigners()
      deployer = accounts[0]
     
      /* execute sale of groceries to another user */
      await superMarket.connect(deployer).createGrocerySale(1, { value: groceryPrice })
     
      /* resell grocery */
      await superMarket.connect(deployer).resellGrocery(1, groceryPrice, { value: listingPrice })
  
      /* query for and return the unsold items */
      items = await superMarket.fetchGroceryItems()
      items = await Promise.all(items.map(async i => {
        const tokenUri = await superMarket.tokenURI(i.groceryId)
        let item = {
          price: i.price.toString(),
          tokenId: i.groceryId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri
        }
        return item
      }))
      console.log('items: ', items)
    })
    it('should create and execute three grocery sales',async () => {

      const SuperMarket = await ethers.getContractFactory("SuperMarket")
      const superMarket = await SuperMarket.deploy()
      await superMarket.deployed()

      let listingPrice = await superMarket.getListingPrice()
      listingPrice = listingPrice.toString()

      accounts = await ethers.getSigners()
      deployer = accounts[0]

      const groceryPrice2 = ethers.utils.parseUnits('1', 'ether')


      await superMarket.createGrocery("https://www.Greatgroceries.com", groceryPrice2, { value: listingPrice })
      await superMarket.createGrocery("https://www.Greatgroceries.com", groceryPrice2, { value: listingPrice })
      await superMarket.createGrocery("https://www.Greatgroceries.com", groceryPrice2, { value: listingPrice })

      await superMarket.connect(deployer).createGrocerySale(2, { value: groceryPrice2 })
      

    })
    it('should fetch total groceries',async () => {

      const SuperMarket = await ethers.getContractFactory("SuperMarket")
      const superMarket = await SuperMarket.deploy()
      await superMarket.deployed()

      let listingPrice = await superMarket.getListingPrice()
      listingPrice = listingPrice.toString()

      accounts = await ethers.getSigners()
      deployer = accounts[0]

      const groceryPrice2 = ethers.utils.parseUnits('1', 'ether')
      let groceryPrice3 = ethers.utils.parseUnits('2', 'ether')

      await superMarket.createGrocery("https://www.Greatgroceries.com", groceryPrice2, { value: listingPrice })
      await superMarket.createGrocery("https://www.Greatgroceries.com", groceryPrice2, { value: listingPrice })
      await superMarket.createGrocery("https://www.Greatgroceries.com", groceryPrice2, { value: listingPrice })

      /* execute sale of groceries to another user */
      await superMarket.connect(deployer).createGrocerySale(1, { value: groceryPrice2 })

      items = await superMarket.fetchMyGroceries()
      items = await Promise.all(items.map(async i => {
        const tokenUri = await superMarket.tokenURI(i.groceryId)
        let item = {
          price: i.price.toString(),
          tokenId: i.groceryId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri
        }
        return item
      }))
      console.log('items: ', items)
    })
      
    })
