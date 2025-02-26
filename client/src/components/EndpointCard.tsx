import { useState } from "react";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import CodeBlock from "./CodeBlock";

interface Parameter {
  name: string;
  type: string;
  required: boolean;
  description: string;
}

interface EndpointCardProps {
  method: "GET" | "POST" | "PUT" | "DELETE";
  endpoint: string;
  description: string;
  parameters?: Parameter[];
  curlExample: string;
  swiftExample: string;
  jsExample: string;
  responseExample: string;
}

const EndpointCard = ({
  method,
  endpoint,
  description,
  parameters = [],
  curlExample,
  swiftExample,
  jsExample,
  responseExample
}: EndpointCardProps) => {
  
  const methodColors = {
    GET: "bg-blue-500",
    POST: "bg-primary",
    PUT: "bg-yellow-500",
    DELETE: "bg-red-500"
  };
  
  return (
    <Card className="mb-6 overflow-hidden border border-[#E5E5E5]">
      <CardHeader className="bg-[#F7F7F8] border-b border-[#E5E5E5] p-4 flex items-center">
        <div className={`${methodColors[method]} text-white text-xs font-semibold rounded px-2 py-1 mr-2`}>
          {method}
        </div>
        <code className="font-mono">{endpoint}</code>
      </CardHeader>
      <CardContent className="p-4">
        <p className="mb-4">{description}</p>
        
        {parameters.length > 0 && (
          <div className="mb-6">
            <h3 className="font-medium mb-2">Request Parameters</h3>
            <div className="overflow-x-auto">
              <table className="min-w-full border border-[#E5E5E5]">
                <thead className="bg-[#F7F7F8]">
                  <tr>
                    <th className="py-2 px-4 border-b text-left">Parameter</th>
                    <th className="py-2 px-4 border-b text-left">Type</th>
                    <th className="py-2 px-4 border-b text-left">Required</th>
                    <th className="py-2 px-4 border-b text-left">Description</th>
                  </tr>
                </thead>
                <tbody>
                  {parameters.map((param, index) => (
                    <tr key={index}>
                      <td className="py-2 px-4 border-b font-mono">{param.name}</td>
                      <td className="py-2 px-4 border-b">{param.type}</td>
                      <td className="py-2 px-4 border-b">{param.required ? "Yes" : "No"}</td>
                      <td className="py-2 px-4 border-b">{param.description}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
        
        <div className="mb-6">
          <h3 className="font-medium mb-2">Example Request</h3>
          <Tabs defaultValue="curl">
            <TabsList className="mb-2">
              <TabsTrigger value="curl">cURL</TabsTrigger>
              <TabsTrigger value="swift">Swift</TabsTrigger>
              <TabsTrigger value="js">JavaScript</TabsTrigger>
            </TabsList>
            <TabsContent value="curl">
              <CodeBlock code={curlExample} language="bash" />
            </TabsContent>
            <TabsContent value="swift">
              <CodeBlock code={swiftExample} language="swift" />
            </TabsContent>
            <TabsContent value="js">
              <CodeBlock code={jsExample} language="javascript" />
            </TabsContent>
          </Tabs>
        </div>
        
        <div>
          <h3 className="font-medium mb-2">Example Response</h3>
          <CodeBlock code={responseExample} language="json" />
        </div>
      </CardContent>
    </Card>
  );
};

export default EndpointCard;
