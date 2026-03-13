using Microsoft.AspNetCore.Mvc;

namespace PricingService.Controllers
{
    [ApiController]
    [Route("api/pricing")]
    public class PricingController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get()
        {
            var port = HttpContext.Connection.LocalPort;

            return Ok(new
            {
                price = 1500,
                port = port,
                message = "Base pricing endpoint"
            });
        }

        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            var port = HttpContext.Connection.LocalPort;

            return Ok(new
            {
                id = id,
                price = 1500 + (id * 100),
                port = port,
                message = $"Pricing for product {id}"
            });
        }

        [HttpPost]
        public IActionResult Calculate([FromBody] PricingRequest request)
        {
            var port = HttpContext.Connection.LocalPort;
            var calculatedPrice = request.BasePrice * request.Quantity * (1 + request.TaxRate);

            return Ok(new
            {
                basePrice = request.BasePrice,
                quantity = request.Quantity,
                taxRate = request.TaxRate,
                totalPrice = calculatedPrice,
                port = port,
                message = "Price calculated successfully"
            });
        }

        [HttpPut("{id}")]
        public IActionResult UpdatePrice(int id, [FromBody] UpdatePriceRequest request)
        {
            var port = HttpContext.Connection.LocalPort;

            return Ok(new
            {
                id = id,
                oldPrice = request.OldPrice,
                newPrice = request.NewPrice,
                port = port,
                message = $"Price updated for product {id}"
            });
        }

        [HttpDelete("{id}")]
        public IActionResult DeletePrice(int id)
        {
            var port = HttpContext.Connection.LocalPort;

            return Ok(new
            {
                id = id,
                port = port,
                message = $"Price deleted for product {id}"
            });
        }
    }

    public class PricingRequest
    {
        public decimal BasePrice { get; set; }
        public int Quantity { get; set; }
        public decimal TaxRate { get; set; }
    }

    public class UpdatePriceRequest
    {
        public decimal OldPrice { get; set; }
        public decimal NewPrice { get; set; }
    }
}