from flask import Flask, render_template, session, redirect, url_for, request
import json
import logging
import logstash
import os

# Flask app setup
app = Flask(__name__)
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'supersecretkey')  # use env var in production

# Load products from JSON
with open('products.json') as f:
    products = json.load(f)

# Configure Logstash
ELK_HOST = os.environ.get('ELK_HOST', 'logstash')
LOGGER = logging.getLogger('python-logstash-logger')
LOGGER.setLevel(logging.INFO)
LOGGER.addHandler(logstash.TCPLogstashHandler(ELK_HOST, 5044, version=1))

@app.route('/')
def index():
    LOGGER.info("User accessed the index page")
    return render_template('index.html', products=products)

@app.route('/product/<int:product_id>')
def product_detail(product_id):
    product = next((p for p in products if p['id'] == product_id), None)
    if not product:
        LOGGER.warning(f"Product ID {product_id} not found")
        return "Product not found", 404
    LOGGER.info(f"User viewed product {product_id}: {product['name']}")
    return render_template('product.html', product=product)

@app.route('/add_to_cart/<int:product_id>', methods=['POST'])
def add_to_cart(product_id):
    quantity = int(request.form.get('quantity', 1))
    if 'cart' not in session:
        session['cart'] = {}
    cart = session['cart']
    cart[str(product_id)] = cart.get(str(product_id), 0) + quantity
    session['cart'] = cart
    LOGGER.info(f"Added product {product_id} (qty={quantity}) to cart")
    return redirect(url_for('cart'))

@app.route('/cart')
def cart():
    cart = session.get('cart', {})
    cart_items = []
    total = 0
    for pid, qty in cart.items():
        product = next((p for p in products if p['id'] == int(pid)), None)
        if product:
            item_total = product['price'] * qty
            total += item_total
            cart_items.append({
                'product': product,
                'quantity': qty,
                'total': item_total
            })
    LOGGER.info(f"Cart viewed: {cart_items}")
    return render_template('cart.html', cart_items=cart_items, total=total)

@app.route('/checkout')
def checkout():
    LOGGER.info("User accessed checkout page")
    return render_template('checkout.html')

@app.route('/clear_cart')
def clear_cart():
    session.pop('cart', None)
    LOGGER.info("Cart cleared")
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8777)


  





