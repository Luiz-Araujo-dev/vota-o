require 'sinatra'
require 'json'

set :bind, '0.0.0.0'
set :port, 4567
set :public_folder, 'public'
set :views, 'views'

$funcionarios = []
$votos = {}

get '/' do
  erb :index
  
end
post '/funcionarios' do
  nome = params['nome']
  cargo = params['cargo']
  
  if nome.empty? || cargo.empty?
    status 400
    return { erro: 'Nome e cargo são obrigatórios' }.to_json
  end
  
  id = $funcionarios.size + 1
  funcionario = { 
    id: id, 
    nome: nome, 
    cargo: cargo, 
    foto: "https://i.pravatar.cc/150?img=#{rand(1..70)}"  # Gera avatar aleatório
  }
  $funcionarios << funcionario
  $votos[id] = 0
  
  status 201
  funcionario.to_json
end


get '/funcionarios' do
  $funcionarios.to_json
end

post '/votar' do
  funcionario_id = params['funcionario_id'].to_i
  
  unless $funcionarios.any? { |f| f[:id] == funcionario_id }
    status 404
    return { erro: 'Funcionário não encontrado' }.to_json
  end
  
  $votos[funcionario_id] += 1
  
  status 200
  { mensagem: 'Voto registrado com sucesso' }.to_json
end

get '/podio' do
  podio = $funcionarios.sort_by { |f| -$votos[f[:id]] }.first(3)
  
  podio_com_votos = podio.map.with_index do |f, index|
    {
      posicao: index + 1,
      id: f[:id],
      nome: f[:nome],
      cargo: f[:cargo],
      votos: $votos[f[:id]],
      foto: f[:foto] || 'avatar-default.png'
    }
  end
  
  podio_com_votos.to_json
end