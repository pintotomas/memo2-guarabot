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

  it '/inscripciones responds with inline keyboard' do
    chat_id = 182_381
    bot_token = '87123879::AAF1823'
    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage?chat_id=#{chat_id}&text=/inscripcion")
    req = Net::HTTP::Get.new(uri)
    req['API_KEY'] = 'fake_key'
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    expect(JSON.parse(response.body[0]['reply_markup']).key?('inline_keyboard')).to eq true
    expect(response.body[0]['text']).to eq 'Seleccione la materia para la inscripcion'
  end

  it '/nota responds with inline keyboard' do
    token = 'fake_token'
    stub_get_updates_for(token, '/nota', 'ingresante')
    stub_send_message(token, 'Seleccione la materia para consultar tu nota')
    app = BotClient.new(token)
    app.run_once
  end

  it '/estado responds with inline keyboard' do
    chat_id = 182_381
    bot_token = '87123879::AAF1823'
    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage?chat_id=#{chat_id}&text=/estado")
    req = Net::HTTP::Get.new(uri)
    req['API_KEY'] = 'fake_key'
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    expect(JSON.parse(response.body[0]['reply_markup']).key?('inline_keyboard')).to eq true
    expect(response.body[0]['text']).to eq 'Seleccione la materia para consultar tu estado'
  end

  describe 'External requests' do
    # it '/oferta external requests for ingresante' do
    #  uri = URI('http://invernalia-guaraapi.herokuapp.com/materias/all?usernameAlumno=ingresante')
    #  req = Net::HTTP::Get.new(uri)
    #  req['API_KEY'] = 'fake_key'
    #  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    #    http.request(req)
    #  end
    #  expect(response.body).to be_an_instance_of(String)
    #  expect(JSON.parse(response.body)['materias'].length).to eq 1
    # end

    it '/oferta devuelve las materias con todos los campos' do # rubocop:disable RSpec/ExampleLength
      token = 'fake_token'
      stub_get_updates_for(token, '/oferta', 'ingresante')
      base_api_url = ENV['URL_API']
      stub_request(:get, base_api_url + 'materias?usernameAlumno=ingresante')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Api-Token' => 'CPLpXxWL8TvM7IXmBRVlRWFiHIbk0jDu',
            'User-Agent' => 'Faraday v0.15.4'
          }
        )
        .to_return(status: 200,
                   body:
      '{"oferta":[{"codigo":1001,"nombre":"Memo2","docente":"Linus Torvalds",
      "cupo_disponible":2,"modalidad":"tareas"}]}')
      stub_send_message(token, 'Materia: Memo2, Codigo: 1001, Docente: Linus Torvalds, Cupos Disponibles: 2, Modalidad: tareas')
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

    it '/promedio ingresante' do
      token = 'fake_token'
      stub_get_updates_for(token, '/promedio', 'ingresante')
      stub_send_message(token, 'Aprobaste 5 materia(s) y tu promedio es 7.75')
      app = BotClient.new(token)
      app.run_once
    end
  end
end
