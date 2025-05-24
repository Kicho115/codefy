//
//  QuestionsViewModel.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 24/05/25.
//

import Foundation
import SwiftUI

@MainActor
class QuestionsViewModel: ObservableObject {
    @Published var questions: [Question] = [
        
        Question(text: "¿Qué caracteriza a una pila (stack)?", options: ["Acceso aleatorio", "FIFO (First In, First Out)", "LIFO (Last In, First Out)", "Ordenamiento estable"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Cómo funciona una cola (queue)?", options: ["LIFO", "FIFO", "Búsqueda binaria", "Ordenación rápida"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Qué diferencia una lista enlazada simple de una doble?", options: ["Solo permite un nodo", "La doble tiene punteros al siguiente y al anterior", "La simple tiene puntero al anterior", "La doble solo tiene un puntero"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Qué hace la recursión?", options: ["Repite bucles hasta un límite", "Llama a una función externa", "Una función se llama a sí misma", "Requiere una variable global"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Qué significa O(n)?", options: ["Tiempo constante", "Tiempo cuadrático", "Tiempo lineal", "Tiempo exponencial"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Qué permite un árbol binario de búsqueda (BST)?", options: ["Acceder a datos secuenciales", "Buscar, insertar y eliminar eficientemente", "Ordenar datos alfabéticamente", "Crear bucles"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Qué hace una tabla hash?", options: ["Ordena datos en array", "Busca elementos de forma secuencial", "Almacena clave-valor con acceso rápido", "Recibe solo datos numéricos"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Qué caracteriza a un algoritmo de ordenamiento estable?", options: ["Mantiene el orden relativo de elementos iguales", "Reordena todos los elementos", "Solo funciona en arrays ordenados", "Tiene complejidad O(n^2)"], correctOptionIndex: 0, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Cuál es la complejidad de búsqueda binaria?", options: ["O(n)", "O(log n)", "O(1)", "O(n^2)"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .estructure),
        Question(text: "¿Qué define un grafo dirigido y ponderado?", options: ["Solo aristas sin peso", "Aristas sin dirección", "Aristas con dirección y peso", "Solo nodos independientes"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .estructure),
        
       
        Question(text: "¿Qué es la encapsulación?", options: ["Ocultar detalles internos y exponer lo necesario", "Crear múltiples instancias de una clase", "Heredar de una superclase", "Acceder libremente a propiedades"], correctOptionIndex: 0, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué representa la herencia?", options: ["Separar lógica en módulos", "Derivar propiedades y métodos de una clase base", "Usar bucles dentro de métodos", "Crear una interfaz"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué es el polimorfismo?", options: ["Crear clases con métodos privados", "Ocultar métodos no utilizados", "Usar una misma interfaz para diferentes implementaciones", "Escribir métodos sin lógica"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué es una clase abstracta?", options: ["Puede instanciarse", "No puede instanciarse y puede tener métodos sin implementación", "Solo tiene variables públicas", "No puede ser heredada"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué define una interfaz?", options: ["Define una base visual", "Define métodos sin implementación", "Oculta todas las propiedades", "Permite múltiples constructores"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué representa un método estático?", options: ["Puede cambiar con cada instancia", "No pertenece a ninguna clase", "Pertenece a la clase y no requiere instancia", "Solo es accesible desde una subclase"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué es la sobrecarga de métodos?", options: ["Tener métodos con diferentes nombres", "Tener varios métodos con el mismo nombre pero distinta firma", "Reescribir todos los métodos", "Combinar métodos en uno solo"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Para qué se usa super?", options: ["Acceder a variables locales", "Llamar al constructor de la superclase", "Crear una instancia", "Eliminar una instancia"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué es el constructor de una clase?", options: ["Una función para inicializar propiedades", "Una función que solo devuelve None", "Un método sin cuerpo", "Un getter para propiedades"], correctOptionIndex: 0, points: 2, createdBy: "Jose", category: .oop),
        Question(text: "¿Qué permite la composición en POO?", options: ["Heredar de múltiples clases", "Combinar múltiples clases sin herencia", "Crear bucles internos", "Ocultar propiedades"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .oop),
     
        Question(text: "¿Qué es HTTP?", options: ["Un protocolo para comunicación entre clientes y servidores", "Un lenguaje de programación", "Un servidor web", "Un método de autenticación"], correctOptionIndex: 0, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es REST?", options: ["Una base de datos", "Un estilo arquitectónico para APIs que usa operaciones HTTP", "Un framework de backend", "Un lenguaje de consulta"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es JSON?", options: ["Un formato para almacenar imágenes", "Un formato ligero para intercambio de datos", "Un protocolo de seguridad", "Un lenguaje de backend"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es un token JWT?", options: ["Un formato de base de datos", "Un protocolo de transmisión", "Un token usado para autenticación con información cifrada", "Un método de encriptación"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es CORS?", options: ["Un mecanismo de seguridad entre dominios", "Un lenguaje de programación", "Un tipo de servidor web", "Un formato de imágenes"], correctOptionIndex: 0, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es un endpoint?", options: ["Un protocolo de autenticación", "Una URL que define un recurso o funcionalidad en una API", "Un archivo de configuración", "Un lenguaje de consulta"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es el middleware en un servidor?", options: ["Un módulo de almacenamiento", "Una capa que procesa solicitudes antes de llegar al controlador", "Un sistema operativo", "Un token de seguridad"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué representa CRUD?", options: ["Crear, leer, actualizar, eliminar", "Crear, revisar, unir, depurar", "Conexión, red, actualización, despliegue", "Crear, renombrar, ubicar, distribuir"], correctOptionIndex: 0, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es SQL?", options: ["Un lenguaje de programación", "Un lenguaje de consulta estructurada para bases de datos", "Un protocolo de transmisión", "Un formato de texto"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .webdev),
        Question(text: "¿Qué es un servidor web?", options: ["Un programa que procesa y entrega contenido web", "Un lenguaje de backend", "Un protocolo de seguridad", "Un cliente web"], correctOptionIndex: 0, points: 2, createdBy: "Jose", category: .webdev),
        
        Question(text: "¿Cómo deberías reaccionar ante un feedback negativo?", options: ["Ignorarlo y seguir trabajando", "Discutirlo inmediatamente", "Aceptar, reflexionar y mejorar", "Cambiar completamente tu enfoque sin razón"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Cuál es una forma efectiva de aprender nuevas tecnologías?", options: ["Esperar a que te lo enseñe alguien", "Investigar por tu cuenta y practicar", "Evitar cambios y seguir con lo que sabes", "Leer un solo libro y confiar en ello"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Qué es importante al priorizar tareas en un proyecto?", options: ["Hacer primero lo que más te guste", "Ignorar las fechas límite", "Considerar la urgencia y el impacto", "Evitar la comunicación con el equipo"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Qué actitud es ideal ante un problema inesperado en un proyecto?", options: ["Culpar a otros", "Buscar soluciones y mantener la calma", "Abandonar el proyecto", "Enfocarse solo en una parte y dejar lo demás"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Cómo manejas el estrés laboral de forma saludable?", options: ["Guardándotelo y trabajando más horas", "Hablando con el equipo y tomando pausas estratégicas", "Evitando hacer nada y descansando indefinidamente", "Culpar al jefe"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Qué esperas de la cultura de una empresa?", options: ["Que sea competitiva y desafiante", "Que fomente el crecimiento y la colaboración", "Que cada quien trabaje solo", "Que siempre haya instrucciones estrictas"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Qué debe hacer un programador al encontrar un error en el código de otro compañero?", options: ["Ignorarlo para no crear problemas", "Corregirlo sin decir nada", "Hablarlo con el compañero y resolverlo juntos", "Reportarlo directamente al jefe sin intentar solucionarlo"], correctOptionIndex: 2, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Cómo reaccionas cuando no entiendes los requisitos de un proyecto?", options: ["Asumes y sigues adelante", "Preguntas a los líderes del proyecto", "Copias lo que hicieron otros", "Dejas la tarea para el final"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .humanResources),
        Question(text: "¿Qué puedes hacer para mantenerte actualizado en tecnologías?", options: ["Evitar aprender cosas nuevas", "Tomar cursos, leer documentación y practicar", "Solo leer lo que comparten en redes sociales", "Dejar que otros del equipo aprendan y te expliquen"], correctOptionIndex: 1, points: 2, createdBy: "Jose", category: .humanResources),
    ]
    
    func addQuestion(_ question: Question) {
        questions.append(question)
    }
    
    var groupedQuestions: [Category: [Question]] {
        Dictionary(grouping: questions, by: { $0.category })
    }
    
    func getRandomQuestion() -> Question? {
        return questions.randomElement()
    }

}
