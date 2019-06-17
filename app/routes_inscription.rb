class RoutesInscription < Routes
  on_message '/oferta' do |bot, message|
    params = { usernameAlumno: message.from.username }
    response = Routes.send_get(params, 'materias')
    response_json = JSON.parse(response.body)
    if response_json['oferta'] == []
      bot.api.send_message(chat_id: message.chat.id, text: 'No hay oferta academica')
    else
      Routes.show_subjects_like_info(bot, message, response_json, 'oferta')
    end
  end

  on_message '/inscripcion' do |bot, message|
    markup = Routes.show_academic_offer_like_options(Routes.send_get(nil, 'materias'))
    bot.api.send_message(chat_id: message.chat.id, text: 'Seleccione la materia para la inscripcion', reply_markup: markup)
  end

  on_message '/estado' do |bot, message|
    markup = Routes.show_academic_offer_like_options(Routes.send_get(nil, 'materias'))
    bot.api.send_message(chat_id: message.chat.id, text: 'Seleccione la materia para consultar tu estado', reply_markup: markup)
  end

  on_message '/nota' do |bot, message|
    markup = Routes.show_academic_offer_like_options(Routes.send_get(nil, 'materias'))
    bot.api.send_message(chat_id: message.chat.id, text: 'Seleccione la materia para consultar tu nota', reply_markup: markup)
  end

  on_response_to 'Seleccione la materia para consultar tu estado' do |bot, message|
    code_message = message.data
    params = { codigoMateria: code_message.to_s, usernameAlumno: message.from.username }
    response = Routes.send_get(params, 'materias/estado')
    request_body = JSON.parse(response.body.gsub('\"', '"'))
    bot.api.send_message(chat_id: message.message.chat.id, text: request_body['estado'])
  end

  on_response_to 'Seleccione la materia para la inscripcion' do |bot, message|
    code_message = message.data
    full_name = message.from.first_name + ' ' + message.from.last_name
    params = { nombre_completo: full_name, codigo_materia: code_message.to_s, username_alumno: message.from.username }
    response = Routes.send_post(params, 'alumnos')
    request_body = JSON.parse(response.body.gsub('\"', '"'))
    if request_body['error'].nil?
      bot.api.send_message(chat_id: message.message.chat.id, text: request_body['resultado'])
    else
      bot.api.send_message(chat_id: message.message.chat.id, text: request_body['error'])
    end
  end

  on_response_to 'Seleccione la materia para consultar tu nota' do |bot, message|
    code_message = message.data
    params = { codigoMateria: code_message.to_s, usernameAlumno: message.from.username }
    response = Routes.send_get(params, 'materias/estado')
    request_body = JSON.parse(response.body.gsub('\"', '"'))
    final_grade = request_body['nota_final'].nil? ? 'Alumno no inscripto o no calificado' : request_body['nota_final']
    bot.api.send_message(chat_id: message.message.chat.id, text: final_grade)
  end

  on_message '/misInscripciones' do |bot, message|
    params = { usernameAlumno: message.from.username }
    response = Routes.send_get(params, 'inscripciones')
    response_json = JSON.parse(response.body)
    if response_json['inscripciones'] == []
      bot.api.send_message(chat_id: message.chat.id, text: 'No tenes inscripciones')
    else
      Routes.show_subjects_like_info(bot, message, response_json, 'inscripciones')
    end
  end
end
