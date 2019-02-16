describe UsersController do 
  
  context '#create' do
    it 'allows creation of a new user' do
      post :create, params: { username: 'jeff', password: 'pass' }, format: :json
      expect(User.count).to eq(1)
      expect(User.first.username).to eq('jeff')
      expect(User.first.salt).not_to be_nil
      expect(response.status).to eq(201)
    end
    
    it 'does not allow creation of a duplicate username' do
      salt = SecureRandom.uuid
      User.create!(username: 'jeff', password: salt + 'pass', salt: salt)

      post :create, params: { username: 'jeff', password: 'moo' }, format: :json
      expect(User.count).to eq(1)
      expect(response.status).to eq(401)
    end
  end
  
  context '#authenticate' do
    it 'allows a user to authenticate with valid credentials' do
      salt = SecureRandom.uuid
      User.create!(username: 'jeff', password: salt + 'pass', salt: salt)
      post :authenticate, params: { username: 'jeff', password: 'pass' }, format: :json
      
      body = JSON.parse(response.body)
      expect(body.keys).to eq(['auth_token'])
      expect(body['auth_token']).not_to be_nil
    end
    
    it 'rejects authentication with invalid credentials' do
      salt = SecureRandom.uuid
      User.create!(username: 'jeff', password: salt + 'pass', salt: salt)
      post :authenticate, params: { username: 'jeff', password: 'MOO wrong password MOO' }, format: :json
      
      body = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(body.keys).to eq(['error'])
      expect(body['error']).to eq({'user_authentication' => ['invalid credentials']})
    end
  end
end