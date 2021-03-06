part of coUserver;

@app.Group('/ah')
class AuctionService
{
	@app.Route('/dropAll')
	Future dropAllAuctions() => postgreSql.innerConn.execute('delete from auctions');

	@app.Route('/list', methods: const[app.POST])
    @Encode()
    Future<List<Auction>> getAuctions(@app.Body(app.JSON) Map parameters)
    {
		String queryString = "select * from auctions";
		parameters.forEach((String key, String value) => queryString += ' $key $value');

		print('query: $queryString');
		return postgreSql.query(queryString, Auction);
    }

    @app.Route('/create', methods: const[app.POST])
    Future addAuction(@Decode() Auction auction) =>
    		postgreSql.execute("insert into auctions (item_name,item_count,total_cost,username,start_time,end_time) "
    						   "values (@item_name, @item_count, @total_cost, @username, @start_time, @end_time)",auction);
}