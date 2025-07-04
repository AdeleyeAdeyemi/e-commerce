from flask import Flask, render_template, session, redirect, url_for, request
import json

app = Flask(__name__)
app.secret_key = 'supersecretkey'

# Load products from JSON
with open('products.json') as f:
    products = json.load(f)

@app.route('/')
def index():
    return render_template('index.html', products=products)

@app.route('/product/<int:product_id>')
def product_detail(product_id):
    product = next((p for p in products if p['id'] == product_id), None)
    if not product:
        return "Product not found", 404
    return render_template('product.html', product=product)

@app.route('/add_to_cart/<int:product_id>', methods=['POST'])
def add_to_cart(product_id):
    quantity = int(request.form.get('quantity', 1))
    if 'cart' not in session:
        session['cart'] = {}
    cart = session['cart']

    if str(product_id) in cart:
        cart[str(product_id)] += quantity
    else:
        cart[str(product_id)] = quantity

    session['cart'] = cart
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
    return render_template('cart.html', cart_items=cart_items, total=total)

@app.route('/checkout')
def checkout():
    # Simple placeholder page
    return render_template('checkout.html')

@app.route('/clear_cart')
def clear_cart():
    session.pop('cart', None)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)

