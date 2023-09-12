# Create Users
alice = User.create!(name: 'Alice', email: 'alice@example.com')
bob = User.create!(name: 'Bob', email: 'bob@example.com')

# Create Articles for Alice and Bob
article_1 = alice.articles.create!(title: 'Alice\'s First Article', content: 'This is the content of Alice\'s first article.')
article_2 = bob.articles.create!(title: 'Bob\'s First Article', content: 'This is the content of Bob\'s first article.')

# Create Comments on Alice's Article by Bob and vice versa
comment_1 = article_1.comments.create!(content: 'Great article, Alice!', user: bob)
comment_2 = article_2.comments.create!(content: 'Well written, Bob!', user: alice)
