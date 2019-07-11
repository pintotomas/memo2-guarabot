require 'spec_helper'
require 'web_mock'
require 'byebug'
WebMock.disable_net_connect!(allow_localhost: false)
# Uncomment to use VCR
# require 'vcr_helper'
require File.dirname(__FILE__) + '/../app/bot_client'

def stub_get_updates(token, message_text)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Tomas', "last_name": 'Pinto', "username": 'tpinto', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Tomas', "last_name": 'Pinto', "username": 'tpinto', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def stub_get_updates_for(token, message_text, user)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Tomas', "last_name": 'Pinto', "username": user, "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Tomas', "last_name": 'Pinto', "username": user, "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def stub_send_message(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'guarabot-prueba', "username": 'invernalia_guarabot' },
                       "chat": { "id": 141_733_544, "first_name": 'Tomas', "last_name": 'Pinto', "username": 'tpinto', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544', 'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

describe 'BotClient' do
  it 'should get a /start message and respond with Hola' do
    token = 'fake_token'
    stub_get_updates(token, '/start')
    stub_send_message(token, 'Hola, Tomas
Para listar los comandos disponibles por favor envia /help')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get an unknown message message and respond with Do not understand' do
    token = 'fake_token'

    stub_get_updates(token, '/unknown')
    stub_send_message(token, 'Uh? No te entiendo! Podes ver los comandos disponibles con /help')

    app = BotClient.new(token)

    app.run_once
  end

  it '/help command' do
    token = 'fake_token'

    stub_get_updates(token, '/help')
    stub_send_message(token, '/oferta Muestra la oferta academica')

    app = BotClient.new(token)

    app.run_once
  end

  it '/nota responds with inline keyboard' do
    token = 'fake_token'
    stub_get_updates_for(token, '/nota', 'ingresante')
    stub_send_message(token, 'Seleccione la materia para consultar tu nota')
    app = BotClient.new(token)
    app.run_once
  end

  it '/nota rdevuelve error' do
    token = 'fake_token'
    stub_get_updates_for(token, '/nota', 'notaconerror')
    stub_send_message(token, 'error en la nota')
    app = BotClient.new(token)
    app.run_once
  end

  it '/estado responds with inline keyboard' do
    token = 'fake_token'
    stub_get_updates_for(token, '/estado', 'ingresante')
    stub_send_message(token, 'Seleccione la materia para consultar tu estado')
    app = BotClient.new(token)
    app.run_once
  end

  it '/estado devuelve error' do
    token = 'fake_token'
    stub_get_updates_for(token, '/estado', 'roberto')

    stub_send_message(token, 'error en el estado')
    app = BotClient.new(token)
    app.run_once
  end

  describe 'External requests' do
    it '/oferta devuelve las materias con todos los campos' do
      token = 'fake_token'
      stub_get_updates_for(token, '/oferta', 'ingresante')

      stub_send_message(token, 'Materia: Memo2, Codigo: 1001, Docente: Linus Torvalds, Cupos Disponibles: 2, Modalidad: tareas')
      app = BotClient.new(token)
      app.run_once
    end

    it '/oferta devuelve mensaje esperado cuando no hay materias' do
      token = 'fake_token'
      stub_get_updates_for(token, '/oferta', 'falafel')

      stub_send_message(token, 'No hay oferta academica')
      app = BotClient.new(token)
      app.run_once
    end

    it '/oferta devuelve error' do
      token = 'fake_token'
      stub_get_updates_for(token, '/oferta', 'erroroferta')

      stub_send_message(token, 'error en la oferta')
      app = BotClient.new(token)
      app.run_once
    end

    it '/inscripcion devuelve error' do
      token = 'fake_token'
      stub_get_updates_for(token, '/inscripcion', 'errorinscripcion')

      stub_send_message(token, 'error en la inscripcion')
      app = BotClient.new(token)
      app.run_once
    end

    it '/inscripcion de materia' do
      token = 'fake_token'
      stub_get_updates_for(token, '/inscripcion', 'ingresante')

      stub_send_message(token, 'Seleccione la materia para la inscripcion')
      app = BotClient.new(token)
      app.run_once
    end

    it '/inscripciones external requests for ingresante' do
      uri = URI('http://invernalia-guaraapi.herokuapp.com/inscripciones?usernameAlumno=pepito')
      req = Net::HTTP::Get.new(uri)
      req['API_KEY'] = 'fake_key'
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      expect(response.body).to be_an_instance_of(String)
      expect(JSON.parse(response.body)['inscripciones'].length).to eq 0
    end

    it '/misInscripciones devuelve mensaje esperado cuando no hay inscripciones' do
      token = 'fake_token'
      stub_get_updates_for(token, '/misInscripciones', 'ingresante')
      base_api_url = ENV['URL_API']
      stub_request(:get, base_api_url + 'inscripciones?usernameAlumno=ingresante')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Api-Token' => 'CPLpXxWL8TvM7IXmBRVlRWFiHIbk0jDu',
            'User-Agent' => 'Faraday v0.15.4'
          }
        )
        .to_return(status: 200, body: '{"inscripciones":[]}', headers: {})

      stub_send_message(token, 'No tenes inscripciones')
      app = BotClient.new(token)
      app.run_once
    end

    it '/misInscripciones devuelve error' do
      token = 'fake_token'
      stub_get_updates_for(token, '/misInscripciones', 'ingresante')
      base_api_url = ENV['URL_API']
      stub_request(:get, base_api_url + 'inscripciones?usernameAlumno=ingresante')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Api-Token' => 'CPLpXxWL8TvM7IXmBRVlRWFiHIbk0jDu',
            'User-Agent' => 'Faraday v0.15.4'
          }
        )
        .to_return(status: 200, body: '{"error":"lindo error"}', headers: {})

      stub_send_message(token, 'lindo error')
      app = BotClient.new(token)
      app.run_once
    end

    it 'test respuesta al seleccionar una materia para consultar estado' do
      # SETUP
      bot = instance_double('bot')
      bot_api = instance_double('bot_apli')
      message = instance_double('message')
      user = instance_double('user')
      chat = instance_double('chat')
      allow(message).to receive(:data).and_return('sarasa')
      allow(message).to receive(:from).and_return(user)
      allow(message).to receive(:message).and_return(message)
      allow(message).to receive(:chat).and_return(chat)
      allow(chat).to receive(:id).and_return('25')
      allow(user).to receive(:username).and_return('tpinto')
      allow(bot_api).to receive(:send_message).with(chat_id: '25', text: nil).and_return('EN_CURSO')
      allow(bot).to receive(:api).and_return(bot_api)
      response = respond_to_subject_status(bot, message)
      expect(response).to eq 'EN_CURSO'
    end

    it 'test respuesta al seleccionar una materia para consultar nota' do
      # SETUP
      bot = instance_double('bot')
      bot_api = instance_double('bot_apli')
      message = instance_double('message')
      user = instance_double('user')
      chat = instance_double('chat')
      allow(message).to receive(:data).and_return('sarasa')
      allow(message).to receive(:from).and_return(user)
      allow(message).to receive(:message).and_return(message)
      allow(message).to receive(:chat).and_return(chat)
      allow(chat).to receive(:id).and_return('25')
      allow(user).to receive(:username).and_return('tpinto')
      allow(bot_api).to receive(:send_message).with(chat_id: '25', text: 'Alumno no inscripto o no calificado').and_return('Alumno no inscripto o no calificado')
      allow(bot).to receive(:api).and_return(bot_api)
      response = respond_to_subject_status_nota(bot, message)
      expect(response).to eq 'Alumno no inscripto o no calificado'
    end

    it '/misInscripciones tiene inscripciones' do
      token = 'fake_token'
      stub_get_updates_for(token, '/misInscripciones', 'ingresanteConInscripciones')
      stub_send_message(token, 'Materia: Algo3, Codigo: 7507, Docente: Carlos Fontela')
      app = BotClient.new(token)
      app.run_once
    end

    it '/promedio ingresante' do
      token = 'fake_token'
      stub_get_updates_for(token, '/promedio', 'ingresante')
      stub_send_message(token, 'Aprobaste 5 materia(s) y tu promedio es 7.75')
      app = BotClient.new(token)
      app.run_once
    end
  end
end
