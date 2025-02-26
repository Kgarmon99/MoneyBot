import { useState } from "react";
import RequestForm from "@/components/RequestForm";
import ResponseView from "@/components/ResponseView";
import { sendChatCompletion, getModels, getMessages } from "@/lib/openai";
import { useToast } from "@/hooks/use-toast";

const ApiPlayground = () => {
  const { toast } = useToast();
  const [response, setResponse] = useState<any | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [status, setStatus] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (requestData: any, apiKey: string) => {
    setIsLoading(true);
    setError(null);
    setResponse(null);
    setStatus(null);
    
    try {
      let result: any;
      
      // Determine which endpoint to call based on the endpoint value
      // This is a simplified example; in a real app, you'd have more robust handling
      if (requestData.model) {
        // This is a chat completion request
        result = await sendChatCompletion(requestData, apiKey);
      } else if (requestData.endpoint === "models") {
        // This is a models request
        result = await getModels(apiKey);
      } else if (requestData.endpoint === "message-history") {
        // This is a message history request
        const conversationId = requestData.conversation_id;
        result = await getMessages(apiKey, conversationId);
      } else {
        // Default to chat completion if not specified
        result = await sendChatCompletion(requestData, apiKey);
      }
      
      setResponse(result);
      setStatus(200);
      
    } catch (err) {
      console.error("API request failed:", err);
      setError(err instanceof Error ? err : new Error(String(err)));
      setStatus(err instanceof Response ? err.status : 500);
      
      toast({
        title: "Request Failed",
        description: err instanceof Error ? err.message : "An unknown error occurred",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="p-4 lg:p-8 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">API Playground</h1>
      <p className="mb-6">
        Test the MoneyBot API endpoints directly in your browser. Enter your API key and request parameters below.
      </p>
      
      <div className="grid grid-cols-1 gap-6">
        <RequestForm onSubmit={handleSubmit} isLoading={isLoading} />
        <ResponseView 
          response={response} 
          error={error} 
          status={status} 
          isLoading={isLoading} 
        />
      </div>
    </div>
  );
};

export default ApiPlayground;
